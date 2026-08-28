package com.wuliuqi.quitmoment

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.ZoneId
import java.time.temporal.ChronoUnit

data class JieKeUiState(
    val profile: QuitProfileEntity? = null,
    val records: List<CravingRecordEntity> = emptyList()
)

class JieKeViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = JieKeRepository(application)
    val state: StateFlow<JieKeUiState> = combine(repository.profile, repository.records) { profile, records ->
        JieKeUiState(profile, records)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), JieKeUiState())

    fun saveProfile(profile: QuitProfileEntity) = viewModelScope.launch { repository.saveProfile(profile) }
    fun addRecord(record: CravingRecordEntity) = viewModelScope.launch { repository.addRecord(record) }
    fun deleteRecord(id: Long) = viewModelScope.launch { repository.deleteRecord(id) }
}

data class QuitMetrics(
    val profile: QuitProfileEntity,
    val records: List<CravingRecordEntity>,
    val now: Long = System.currentTimeMillis()
) {
    private val zone get() = ZoneId.systemDefault()
    private val nowInstant get() = Instant.ofEpochMilli(now)
    val avoidedCount get() = records.count { !it.didSmoke }
    val smokedCount get() = records.filter { it.didSmoke }.sumOf { it.cigaretteCount }
    val savedMoney get() = avoidedCount.toDouble() / profile.cigarettesPerPack.coerceAtLeast(1) * profile.packPrice
    val spentMoney get() = smokedCount.toDouble() / profile.cigarettesPerPack.coerceAtLeast(1) * profile.packPrice
    val todayRecords get() = records.filter { Instant.ofEpochMilli(it.createdAt).atZone(zone).toLocalDate() == nowInstant.atZone(zone).toLocalDate() }
    val todayCravings get() = todayRecords.size
    val relapseFreeStart get() = maxOf(profile.quitAt, records.filter { it.didSmoke }.maxOfOrNull { it.createdAt } ?: profile.quitAt)
    val elapsedText: String get() {
        val minutes = ((now - profile.quitAt).coerceAtLeast(0) / 60_000).toInt()
        return when {
            minutes >= 1_440 -> "${minutes / 1_440} 天 ${(minutes % 1_440) / 60} 小时"
            minutes >= 60 -> "${minutes / 60} 小时 ${minutes % 60} 分钟"
            else -> "$minutes 分钟"
        }
    }
    val relapseFreeText: String get() {
        val hours = ((now - relapseFreeStart).coerceAtLeast(0) / 3_600_000).toInt()
        return if (hours >= 24) "${hours / 24} 天 ${hours % 24} 小时" else "$hours 小时"
    }
    fun recordsForDays(days: Long): List<CravingRecordEntity> = records.filter {
        Instant.ofEpochMilli(it.createdAt).isAfter(nowInstant.minus(days, ChronoUnit.DAYS))
    }
}

val defaultMoods = listOf("平静", "焦虑", "烦躁", "疲惫", "开心", "压力大")
val defaultTriggers = listOf("饭后", "工作压力", "社交", "喝酒", "开车", "无聊", "看到别人抽烟", "其他")

data class HealthMilestone(val hours: Int, val title: String, val benefit: String) {
    companion object {
        val all = listOf(
            HealthMilestone(0, "开始恢复", "停止吸烟后，身体开始排出一氧化碳。"),
            HealthMilestone(8, "8 小时", "一氧化碳水平下降，氧气运输逐步改善。"),
            HealthMilestone(24, "24 小时", "心脏病风险开始下降。"),
            HealthMilestone(48, "48 小时", "嗅觉和味觉可能开始恢复。"),
            HealthMilestone(72, "72 小时", "支气管开始放松，呼吸可能更轻松。"),
            HealthMilestone(168, "1 周", "循环和肺部功能持续改善。"),
            HealthMilestone(720, "1 个月", "咳嗽和气短可能减少。"),
            HealthMilestone(8760, "1 年", "冠心病风险可显著下降。")
        )
    }
}
