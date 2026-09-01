package com.wuliuqi.quitmoment

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Gamepad
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.PI
import kotlin.math.sin
import kotlin.random.Random

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RescueSheet(onDismiss: () -> Unit, onSave: (CravingRecordEntity) -> Unit) {
    var intensity by remember { mutableIntStateOf(5) }
    var trigger by remember { mutableStateOf(defaultTriggers.first()) }
    var mood by remember { mutableStateOf(defaultMoods.first()) }
    var showGame by remember { mutableStateOf(false) }
    ModalBottomSheet(onDismissRequest = onDismiss) {
        if (showGame) FocusGame(onExit = { showGame = false }) else {
            LazyColumn(Modifier.fillMaxWidth().padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                item { Text("烟瘾急救", fontSize = 24.sp, fontWeight = FontWeight.Black) }
                item { Text("给自己 3 分钟", fontSize = 25.sp, fontWeight = FontWeight.Bold, modifier = Modifier.fillMaxWidth(), textAlign = androidx.compose.ui.text.style.TextAlign.Center) }
                item { BreathingOrb() }
                item { Text("吸气 4 秒，停住 2 秒，呼气 6 秒。烟瘾会像浪一样退去。", color = Color.Gray, modifier = Modifier.fillMaxWidth(), textAlign = androidx.compose.ui.text.style.TextAlign.Center) }
                item { Card { Column(Modifier.padding(16.dp)) { Text("当前强度：$intensity / 10", fontWeight = FontWeight.Bold); Slider(value = intensity.toFloat(), onValueChange = { intensity = it.toInt() }, valueRange = 1f..10f, steps = 8) } } }
                item { Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) { RescueAction("💧", "喝水"); RescueAction("🚶", "走动"); RescueAction("✨", "转移注意") } }
                item { FilledTonalButton({ showGame = true }, Modifier.fillMaxWidth()) { Icon(Icons.Default.Gamepad, null); Spacer(Modifier.width(8.dp)); Text("玩 2 分钟专注小游戏") } }
                item { Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) { ChoicePicker("诱因", trigger, defaultTriggers, Modifier.weight(1f)) { trigger = it }; ChoicePicker("心情", mood, defaultMoods, Modifier.weight(1f)) { mood = it } } }
                item { Button({ onSave(CravingRecordEntity(intensity = intensity, trigger = trigger, mood = mood)); }, Modifier.fillMaxWidth().height(52.dp)) { Text("我坚持过去了", fontWeight = FontWeight.Bold, fontSize = 17.sp) } }
                item { OutlinedButton({ onSave(CravingRecordEntity(intensity = intensity, trigger = trigger, mood = mood, didSmoke = true, cigaretteCount = 1)); }, Modifier.fillMaxWidth()) { Text("我复吸了", color = Red) } }
                item { Spacer(Modifier.height(24.dp)) }
            }
        }
    }
}

@Composable
private fun BreathingOrb() {
    val transition = rememberInfiniteTransition(label = "breath")
    val leftUp by transition.animateFloat(0f, 1f, infiniteRepeatable(tween(4200, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "leftUp")
    val rightDown by transition.animateFloat(0f, 1f, infiniteRepeatable(tween(3600, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "rightDown")
    val center by transition.animateFloat(.86f, 1.13f, infiniteRepeatable(tween(3800, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "center")
    Box(Modifier.fillMaxWidth().height(230.dp), contentAlignment = Alignment.Center) {
        Box(Modifier.size(210.dp).padding(0.dp).clip(CircleShape).background(Blue.copy(alpha = .10f)))
        Box(Modifier.size(185.dp).padding(start = (rightDown * 24).dp, top = (rightDown * 20).dp).clip(CircleShape).background(Teal.copy(alpha = .15f)))
        Box(Modifier.size((150 * center).dp).clip(CircleShape).background(Blue.copy(alpha = .28f)))
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            RescueCountdown()
        }
    }
}

@Composable
private fun RescueCountdown() {
    var remaining by remember { mutableIntStateOf(180) }
    LaunchedEffect(Unit) { while (remaining > 0) { delay(1_000); remaining-- } }
    Text("慢慢呼吸", fontWeight = FontWeight.Bold)
    Text("${remaining / 60}:${"%02d".format(remaining % 60)}", fontSize = 38.sp, fontWeight = FontWeight.Black)
}

@Composable private fun RescueAction(icon: String, text: String) { Column(horizontalAlignment = Alignment.CenterHorizontally) { Text(icon, fontSize = 24.sp); Text(text, fontWeight = FontWeight.SemiBold) } }

@Composable
private fun ChoicePicker(title: String, selected: String, options: List<String>, modifier: Modifier = Modifier, onSelect: (String) -> Unit) {
    var expanded by remember { mutableStateOf(false) }
    Box(modifier) {
        OutlinedButton({ expanded = true }, Modifier.fillMaxWidth()) { Column(Modifier.fillMaxWidth()) { Text(title, fontSize = 12.sp, color = Color.Gray); Text(selected, fontWeight = FontWeight.Bold) } }
        DropdownMenu(expanded, { expanded = false }) { options.forEach { DropdownMenuItem({ Text(it) }, { onSelect(it); expanded = false }) } }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuickRecordSheet(onDismiss: () -> Unit, onSave: (CravingRecordEntity) -> Unit) {
    var intensity by remember { mutableIntStateOf(5) }
    var trigger by remember { mutableStateOf(defaultTriggers.first()) }
    var mood by remember { mutableStateOf(defaultMoods.first()) }
    var note by remember { mutableStateOf("") }
    var didSmoke by remember { mutableStateOf(false) }
    var count by remember { mutableIntStateOf(1) }
    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Text("记录一次", fontWeight = FontWeight.Black, fontSize = 24.sp)
            Text("烟瘾强度：$intensity / 10", fontWeight = FontWeight.Bold); Slider(value = intensity.toFloat(), onValueChange = { intensity = it.toInt() }, valueRange = 1f..10f, steps = 8)
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) { FilterChip(!didSmoke, { didSmoke = false }, { Text("少吸成功") }); FilterChip(didSmoke, { didSmoke = true }, { Text("复吸") }) }
            if (didSmoke) Row(verticalAlignment = Alignment.CenterVertically) { Text("抽了 $count 根"); Spacer(Modifier.width(12.dp)); OutlinedButton({ count = (count - 1).coerceAtLeast(1) }) { Text("－") }; OutlinedButton({ count++ }) { Text("＋") } }
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) { ChoicePicker("诱因", trigger, defaultTriggers, Modifier.weight(1f)) { trigger = it }; ChoicePicker("心情", mood, defaultMoods, Modifier.weight(1f)) { mood = it } }
            OutlinedTextField(value = note, onValueChange = { note = it }, label = { Text("备注（可选）") }, modifier = Modifier.fillMaxWidth())
            Button({ onSave(CravingRecordEntity(intensity = intensity, trigger = trigger, mood = mood, note = note, didSmoke = didSmoke, cigaretteCount = if (didSmoke) count else 0)) }, Modifier.fillMaxWidth()) { Text("保存记录") }
            Spacer(Modifier.height(16.dp))
        }
    }
}

@Composable
fun RecordsScreen(records: List<CravingRecordEntity>, onAdd: () -> Unit, onDelete: (Long) -> Unit) {
    var filter by remember { mutableStateOf("全部") }
    val shown = records.filter { filter == "全部" || (filter == "少吸" && !it.didSmoke) || (filter == "复吸" && it.didSmoke) }
    LazyColumn(Modifier.fillMaxSize().padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        item { Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) { Text("记录", fontSize = 34.sp, fontWeight = FontWeight.Black); Spacer(Modifier.weight(1f)); IconButton(onAdd) { Icon(Icons.Default.Add, "添加") } } }
        item { Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) { listOf("全部", "少吸", "复吸").forEach { FilterChip(filter == it, { filter = it }, { Text(it) }) } } }
        if (shown.isEmpty()) item { EmptyState("还没有记录", "记录烟瘾、心情和诱因，了解自己的戒烟过程。") }
        items(shown, key = { it.id }) { record -> RecordRow(record, { onDelete(record.id) }) }
        item { Spacer(Modifier.height(20.dp)) }
    }
}

@Composable
private fun RecordRow(record: CravingRecordEntity, onDelete: () -> Unit) {
    val format = remember { SimpleDateFormat("MM月dd日 HH:mm", Locale.CHINA) }
    Card { Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) { Icon(if (record.didSmoke) Icons.Default.Warning else Icons.Default.CheckCircle, null, tint = if (record.didSmoke) Red else Green); Spacer(Modifier.width(12.dp)); Column(Modifier.weight(1f)) { Text(if (record.didSmoke) "已抽烟 ${record.cigaretteCount} 根" else "成功少吸", fontWeight = FontWeight.Bold, fontSize = 17.sp); Text("强度 ${record.intensity} · ${record.mood} · ${record.trigger}", color = Color.Gray, maxLines = 1, overflow = TextOverflow.Ellipsis); if (record.note.isNotBlank()) Text(record.note, color = Color.Gray, maxLines = 1, overflow = TextOverflow.Ellipsis) }; Column(horizontalAlignment = Alignment.End) { Text(format.format(Date(record.createdAt)), color = Color.Gray, fontSize = 12.sp); IconButton(onDelete) { Icon(Icons.Default.Delete, "删除", tint = Red) } } } }
}

@Composable
fun TrendsScreen(metrics: QuitMetrics) {
    var period by remember { mutableStateOf("本周") }
    val records = when (period) { "当日" -> metrics.todayRecords; "本月" -> metrics.recordsForDays(30); "本年" -> metrics.recordsForDays(365); else -> metrics.recordsForDays(7) }
    LazyColumn(Modifier.fillMaxSize().padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item { Text("趋势", fontSize = 34.sp, fontWeight = FontWeight.Black) }
        item { Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) { listOf("当日", "本周", "本月", "本年").forEach { FilterChip(period == it, { period = it }, { Text(it) }) } } }
        item { TrendChart(records, period) }
        item { SummaryCard("当期复吸记录", listOf("复吸" to "${records.count { it.didSmoke }} 次", "抽了" to "${records.filter { it.didSmoke }.sumOf { it.cigaretteCount }} 根", "浪费" to "¥${"%.2f".format(records.filter { it.didSmoke }.sumOf { it.cigaretteCount }.toDouble() / metrics.profile.cigarettesPerPack * metrics.profile.packPrice)}", "摄入焦油" to "${"%.1f".format(records.filter { it.didSmoke }.sumOf { it.cigaretteCount } * metrics.profile.tarMilligramsPerCigarette)} mg")) }
        item { SummaryCard("戒烟累计", listOf("节省" to "¥${"%.2f".format(metrics.savedMoney)}", "少吸" to "${metrics.avoidedCount} 根", "已成功度过" to "${metrics.avoidedCount} 次")) }
        item { Text("戒烟日历", fontWeight = FontWeight.Black, fontSize = 22.sp) }
        item { QuitCalendar(metrics.records) }
        item { Spacer(Modifier.height(20.dp)) }
    }
}

@Composable
private fun TrendChart(records: List<CravingRecordEntity>, period: String) {
    val success = records.count { !it.didSmoke }
    val relapse = records.count { it.didSmoke }
    Card { Column(Modifier.padding(18.dp)) { Text("$period 烟瘾", fontWeight = FontWeight.Bold); Spacer(Modifier.height(12.dp)); Canvas(Modifier.fillMaxWidth().height(180.dp)) { val max = maxOf(1, success + relapse); val barW = size.width / 4; val sH = size.height * success / max; val rH = size.height * relapse / max; drawLine(Color.LightGray, Offset(0f, size.height), Offset(size.width, size.height), 2f); drawRoundRect(Green, Offset(barW * .7f, size.height - sH), androidx.compose.ui.geometry.Size(barW, sH), CornerRadius(10f)); drawRoundRect(Red, Offset(barW * .7f, size.height - sH - rH), androidx.compose.ui.geometry.Size(barW, rH), CornerRadius(10f)) }; Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) { Text("绿色：少吸 $success 次", color = Green); Text("红色：复吸 $relapse 次", color = Red) } } }
}

@Composable
private fun SummaryCard(title: String, values: List<Pair<String, String>>) {
    Card {
        Column(Modifier.padding(18.dp)) {
            Text(title, fontWeight = FontWeight.Bold, fontSize = 19.sp)
            values.forEachIndexed { index, (label, value) ->
                if (index > 0) HorizontalDivider(Modifier.padding(vertical = 9.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(label)
                    Text(value, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
private fun QuitCalendar(records: List<CravingRecordEntity>) {
    val days = (0 until 28).map { System.currentTimeMillis() - it * 86_400_000L }.reversed()
    Card {
        Column(Modifier.padding(16.dp)) {
            Text("最近 28 天", color = Color.Gray)
            days.chunked(7).forEach { week ->
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                    week.forEach { day ->
                        val hasSuccess = records.any { !it.didSmoke && kotlin.math.abs(it.createdAt - day) < 86_400_000L }
                        Box(
                            Modifier.size(30.dp).padding(3.dp).clip(CircleShape)
                                .background(if (hasSuccess) Green else Color.LightGray.copy(alpha = .4f))
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun EmptyState(title: String, detail: String) { Column(Modifier.fillMaxWidth().padding(vertical = 100.dp), horizontalAlignment = Alignment.CenterHorizontally) { Icon(Icons.Default.Info, null, tint = Color.Gray, modifier = Modifier.size(50.dp)); Spacer(Modifier.height(12.dp)); Text(title, fontWeight = FontWeight.Bold, fontSize = 22.sp); Text(detail, color = Color.Gray, modifier = Modifier.padding(top = 8.dp), textAlign = androidx.compose.ui.text.style.TextAlign.Center) } }

@Composable
fun SettingsScreen(profile: QuitProfileEntity, onSave: (QuitProfileEntity) -> Unit) {
    var perDay by remember(profile) { mutableIntStateOf(profile.cigarettesPerDay) }
    var price by remember(profile) { mutableStateOf(profile.packPrice.toString()) }
    var perPack by remember(profile) { mutableIntStateOf(profile.cigarettesPerPack) }
    var years by remember(profile) { mutableIntStateOf(profile.smokingYears) }
    var tar by remember(profile) { mutableStateOf(profile.tarMilligramsPerCigarette.toString()) }
    var scenes by remember(profile) { mutableStateOf(profile.highRiskScenes) }
    LazyColumn(Modifier.fillMaxSize().padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        item { Text("戒烟资料", fontWeight = FontWeight.Black, fontSize = 28.sp) }
        item { NumberStepper(perDay, "根 / 天") { perDay = it.coerceIn(1, 100) } }
        item { OutlinedTextField(value = price, onValueChange = { price = it }, label = { Text("每包价格（元）") }, modifier = Modifier.fillMaxWidth()) }
        item { NumberStepper(perPack, "根 / 包") { perPack = it.coerceIn(1, 100) } }
        item { NumberStepper(years, "年烟龄") { years = it.coerceIn(0, 80) } }
        item { OutlinedTextField(value = tar, onValueChange = { tar = it }, label = { Text("每支焦油（mg）") }, modifier = Modifier.fillMaxWidth()) }
        item { OutlinedTextField(value = scenes, onValueChange = { scenes = it }, label = { Text("高风险场景") }, modifier = Modifier.fillMaxWidth(), minLines = 2) }
        item { Button({ onSave(profile.copy(cigarettesPerDay = perDay, packPrice = price.toDoubleOrNull() ?: profile.packPrice, cigarettesPerPack = perPack, smokingYears = years, tarMilligramsPerCigarette = tar.toDoubleOrNull() ?: profile.tarMilligramsPerCigarette, highRiskScenes = scenes)) }, Modifier.fillMaxWidth()) { Text("保存资料") } }
        item { Text("通知、小组件、Health Connect 与监督戒烟会在后续云端同步版本接入。", color = Color.Gray, fontSize = 13.sp) }
    }
}

@Composable
fun EducationScreen() {
    val articles = listOf(
        "吸烟对身体的影响" to "烟草烟雾含有多种有害物质。戒烟无论从何时开始，都会带来健康收益。",
        "如何科学戒烟" to "提前识别诱因、设定应对动作、记录每次烟瘾，并在需要时咨询医生或戒烟门诊。",
        "烟瘾来时怎么办" to "先离开触发场景，喝水、走动、进行缓慢呼吸或短时专注活动。烟瘾会过去。",
        "复吸不是归零" to "如实记录复吸的时间、诱因和感受；下一次为这个场景准备一个更小、能完成的动作。",
        "备孕与孕期：两个人一起戒烟" to "备孕期建议男女双方尽早戒烟并避免二手烟。孕期吸烟和二手烟暴露会增加不良妊娠与婴儿健康风险，应寻求专业支持。"
    )
    var selected by remember { mutableStateOf<Pair<String, String>?>(null) }
    if (selected != null) {
        val article = selected ?: return
        LazyColumn(Modifier.fillMaxSize().padding(22.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) { item { Text(article.first, fontWeight = FontWeight.Black, fontSize = 30.sp) }; item { Text(article.second, fontSize = 18.sp, lineHeight = 30.sp) }; item { Text("提示：科普内容不能替代医疗诊断。若出现胸痛、呼吸困难、孕期相关疑虑或戒断症状难以应对，请及时咨询医生或当地戒烟服务。", color = Color.Gray) } }
    } else {
        LazyColumn(Modifier.fillMaxSize().padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) { item { Text("戒烟科普", fontWeight = FontWeight.Black, fontSize = 34.sp); Text("用科学知识陪你走过每一次想抽烟。", color = Color.Gray) }; items(articles) { article -> Card(Modifier.fillMaxWidth().clickable { selected = article }) { Column(Modifier.padding(20.dp)) { Text(article.first, fontWeight = FontWeight.Bold, fontSize = 19.sp); Spacer(Modifier.height(5.dp)); Text(article.second, color = Color.Gray, maxLines = 2, overflow = TextOverflow.Ellipsis) } } } }
    }
}

@Composable
private fun FocusGame(onExit: () -> Unit) {
    var remaining by remember { mutableIntStateOf(120) }
    var score by remember { mutableIntStateOf(0) }
    var streak by remember { mutableIntStateOf(0) }
    var position by remember { mutableStateOf(Offset(.50f, .50f)) }
    var pulseTarget by remember { mutableStateOf(1f) }
    val pulse by animateFloatAsState(pulseTarget, animationSpec = tween(900, easing = FastOutSlowInEasing), label = "lightPulse")
    val isFinished = remaining <= 0
    fun randomPosition() = Offset(Random.nextFloat() * .64f + .16f, Random.nextFloat() * .62f + .16f)
    fun capture() {
        score++
        streak++
        position = randomPosition()
        pulseTarget = if (pulseTarget == 1f) 1.18f else 1f
    }
    LaunchedEffect(Unit) { while (remaining > 0) { delay(1_000); remaining-- } }
    LaunchedEffect(Unit) {
        while (remaining > 0) {
            delay(2_800)
            if (remaining > 0) { streak = 0; position = randomPosition() }
        }
    }
    Column(Modifier.fillMaxSize().padding(18.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Text("烟瘾急救小游戏", fontWeight = FontWeight.Black, fontSize = 22.sp)
            OutlinedButton(onExit) { Text("退出") }
        }
        Text(if (isFinished) "你完成了两分钟的转移注意" else "捕光挑战", color = Purple, fontWeight = FontWeight.Bold, fontSize = 23.sp)
        Text(if (isFinished) "你给自己留出了一段缓冲。" else if (streak >= 3) "连击中，烟瘾正在慢慢过去。" else "跟着光点，把注意力留在当下", color = Color.Gray)
        Card(Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = Color(0xFFE9E7FF))) {
            Row(Modifier.padding(horizontal = 18.dp, vertical = 13.dp).fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Column { Text("已捕光 $score 次", fontWeight = FontWeight.Bold); Text("当前连击 ×$streak", color = Color.Gray, fontSize = 13.sp) }
                Text(if (isFinished) "完成" else "${remaining / 60}:${"%02d".format(remaining % 60)}", color = if (isFinished) Green else Purple, fontWeight = FontWeight.Black, fontSize = 22.sp)
            }
        }
        BoxWithConstraints(Modifier.fillMaxWidth().weight(1f).clip(RoundedCornerShape(28.dp)).background(Color(0xFFDCEEFF))) {
            Canvas(Modifier.fillMaxSize()) {
                repeat(12) { index ->
                    val x = size.width * (((index * 37) % 92 + 4) / 100f)
                    val y = size.height * (((index * 23) % 84 + 8) / 100f)
                    drawCircle(Color.White.copy(alpha = if (index % 2 == 0) .34f else .18f), radius = 3f + (index % 3) * 2f, center = Offset(x, y))
                }
            }
            if (isFinished) {
                Column(Modifier.align(Alignment.Center), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("✦", color = Green, fontSize = 54.sp)
                    Text("两分钟完成", fontWeight = FontWeight.Black, fontSize = 24.sp)
                    Text("已捕捉 $score 束光", color = Color.Gray)
                }
            } else {
                Box(
                    Modifier.align(Alignment.TopStart)
                        .padding(start = maxWidth * position.x, top = maxHeight * position.y)
                        .size((74 * pulse).dp).clip(CircleShape).background(Blue.copy(alpha = .22f))
                        .padding(10.dp).clip(CircleShape).background(Blue).clickable { capture() },
                    contentAlignment = Alignment.Center
                ) { Text("✦", color = Color.White, fontWeight = FontWeight.Black, fontSize = 28.sp) }
            }
        }
        Text("光点会自己换位，不用追求分数；把这两分钟留给自己就好。", color = Color.Gray, textAlign = androidx.compose.ui.text.style.TextAlign.Center)
        if (isFinished) Button(onExit, Modifier.fillMaxWidth()) { Text("完成，回到急救") }
    }
}
