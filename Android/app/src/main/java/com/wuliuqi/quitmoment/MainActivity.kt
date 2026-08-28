package com.wuliuqi.quitmoment

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
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
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.ShowChart
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent { JieKeTheme { JieKeApp() } }
    }
}

val Blue = Color(0xFF0A84FF)
val Teal = Color(0xFF12BFA8)
val Green = Color(0xFF30C759)
val Red = Color(0xFFFF453A)
val Purple = Color(0xFF6750E8)

@Composable
fun JieKeTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = MaterialTheme.colorScheme.copy(primary = Blue, secondary = Teal), content = content)
}

private enum class AppTab(val label: String) { HOME("首页"), RECORDS("记录"), TRENDS("趋势") }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun JieKeApp(viewModel: JieKeViewModel = viewModel()) {
    val ui by viewModel.state.collectAsStateWithLifecycle()
    var tab by remember { mutableStateOf(AppTab.HOME) }
    var screen by remember { mutableStateOf("main") }
    var showRescue by remember { mutableStateOf(false) }
    var showQuickRecord by remember { mutableStateOf(false) }

    if (ui.profile == null) {
        Onboarding { viewModel.saveProfile(it) }
        return
    }
    val profile = ui.profile ?: return
    val metrics = remember(profile, ui.records) { QuitMetrics(profile, ui.records) }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text(if (screen == "main") "戒刻" else screen, fontWeight = FontWeight.Bold) },
                actions = {
                    if (screen == "main") IconButton(onClick = { screen = "设置" }) { Icon(Icons.Default.Settings, "设置") }
                    else IconButton(onClick = { screen = "main" }) { Icon(Icons.Default.Close, "关闭") }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(containerColor = Color.Transparent)
            )
        },
        bottomBar = {
            if (screen == "main") NavigationBar {
                NavigationBarItem(selected = tab == AppTab.HOME, onClick = { tab = AppTab.HOME }, icon = { Icon(Icons.Default.Home, null) }, label = { Text("首页") })
                NavigationBarItem(selected = tab == AppTab.RECORDS, onClick = { tab = AppTab.RECORDS }, icon = { Icon(Icons.Outlined.Edit, null) }, label = { Text("记录") })
                NavigationBarItem(selected = tab == AppTab.TRENDS, onClick = { tab = AppTab.TRENDS }, icon = { Icon(Icons.Default.ShowChart, null) }, label = { Text("趋势") })
            }
        }
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (screen) {
                "设置" -> SettingsScreen(profile, onSave = viewModel::saveProfile)
                "戒烟科普" -> EducationScreen()
                else -> when (tab) {
                    AppTab.HOME -> HomeScreen(metrics, onRescue = { showRescue = true }, onEducation = { screen = "戒烟科普" })
                    AppTab.RECORDS -> RecordsScreen(ui.records, onAdd = { showQuickRecord = true }, onDelete = viewModel::deleteRecord)
                    AppTab.TRENDS -> TrendsScreen(metrics)
                }
            }
        }
    }
    if (showRescue) RescueSheet(onDismiss = { showRescue = false }, onSave = { viewModel.addRecord(it); showRescue = false })
    if (showQuickRecord) QuickRecordSheet(onDismiss = { showQuickRecord = false }, onSave = { viewModel.addRecord(it); showQuickRecord = false })
}

@Composable
private fun Onboarding(onComplete: (QuitProfileEntity) -> Unit) {
    var step by remember { mutableIntStateOf(0) }
    var perDay by remember { mutableIntStateOf(10) }
    var price by remember { mutableStateOf("20") }
    var perPack by remember { mutableIntStateOf(20) }
    var years by remember { mutableIntStateOf(5) }
    var scene by remember { mutableStateOf("饭后、工作压力") }
    val title = listOf("你每天大约抽几根？", "一包烟多少钱？", "每包有多少根？", "你的烟龄有多久？", "最容易想抽烟的场景？")[step]
    Scaffold { padding ->
        Column(Modifier.padding(padding).padding(28.dp).fillMaxSize(), verticalArrangement = Arrangement.SpaceBetween) {
            Column(verticalArrangement = Arrangement.spacedBy(24.dp)) {
                Text("戒刻", color = Blue, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                Text("${step + 1} / 5", color = MaterialTheme.colorScheme.onSurfaceVariant)
                Text(title, style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold)
                when (step) {
                    0 -> NumberStepper(perDay, "根 / 天") { perDay = it.coerceIn(1, 100) }
                    1 -> OutlinedTextField(price, { price = it }, label = { Text("价格（元）") }, modifier = Modifier.fillMaxWidth())
                    2 -> NumberStepper(perPack, "根 / 包") { perPack = it.coerceIn(1, 100) }
                    3 -> NumberStepper(years, "年") { years = it.coerceIn(0, 80) }
                    4 -> OutlinedTextField(scene, { scene = it }, label = { Text("例如：饭后、喝酒、开车") }, modifier = Modifier.fillMaxWidth(), minLines = 3)
                }
            }
            Button(
                onClick = {
                    if (step < 4) step++ else onComplete(QuitProfileEntity(cigarettesPerDay = perDay, packPrice = price.toDoubleOrNull() ?: 20.0, cigarettesPerPack = perPack, smokingYears = years, highRiskScenes = scene))
                }, modifier = Modifier.fillMaxWidth().height(54.dp)
            ) { Text(if (step == 4) "开始戒烟" else "继续", fontSize = 17.sp) }
        }
    }
}

@Composable
fun NumberStepper(value: Int, unit: String, onChange: (Int) -> Unit) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly, verticalAlignment = Alignment.CenterVertically) {
        OutlinedButton(onClick = { onChange(value - 1) }) { Text("－", fontSize = 26.sp) }
        Column(horizontalAlignment = Alignment.CenterHorizontally) { Text("$value", fontSize = 58.sp, color = Blue, fontWeight = FontWeight.Bold); Text(unit, color = MaterialTheme.colorScheme.onSurfaceVariant) }
        OutlinedButton(onClick = { onChange(value + 1) }) { Text("＋", fontSize = 26.sp) }
    }
}

@Composable
private fun HomeScreen(metrics: QuitMetrics, onRescue: () -> Unit, onEducation: () -> Unit) {
    val scope = rememberCoroutineScope()
    var tick by remember { mutableStateOf(System.currentTimeMillis()) }
    LaunchedEffect(Unit) { while (true) { delay(60_000); tick = System.currentTimeMillis() } }
    val current = metrics.copy(now = tick)
    LazyColumn(Modifier.fillMaxSize().padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item { Spacer(Modifier.height(6.dp)); Text("戒刻", style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.Black) }
        item {
            GradientCard(Teal) {
                Text("已戒烟", color = Color.White.copy(alpha = .8f))
                Text(current.elapsedText, color = Color.White, fontSize = 34.sp, fontWeight = FontWeight.Black)
                Text("连续无复吸 ${current.relapseFreeText}", color = Color.White.copy(alpha = .9f))
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                MetricCard("少吸", "${current.avoidedCount} 根", Blue, Modifier.weight(1f))
                MetricCard("节省", "¥${"%.2f".format(current.savedMoney)}", Blue, Modifier.weight(1f))
                MetricCard("今日烟瘾", "${current.todayCravings} 次", Blue, Modifier.weight(1f))
            }
        }
        item { Text("每次少吸，计为少抽 1 支；已经成功度过 ${current.avoidedCount} 次烟瘾。", color = MaterialTheme.colorScheme.onSurfaceVariant) }
        item { Button(onRescue, Modifier.fillMaxWidth().height(58.dp), shape = RoundedCornerShape(24.dp)) { Icon(Icons.Default.Favorite, null); Spacer(Modifier.width(8.dp)); Text("我现在想抽烟", fontSize = 19.sp, fontWeight = FontWeight.Bold) } }
        item { DailyPlanCard(current) }
        item { HealthCard(current) }
        item { Card(Modifier.fillMaxWidth().clickable { onEducation() }, colors = CardDefaults.cardColors(containerColor = Color(0xFFF5EEFF))) { Column(Modifier.padding(20.dp)) { Text("戒烟科普", color = Purple, fontWeight = FontWeight.Bold); Text("科学戒烟、复吸应对、备孕与孕期", fontSize = 20.sp, fontWeight = FontWeight.Bold); Text("了解知识，给每次选择多一份把握。", color = MaterialTheme.colorScheme.onSurfaceVariant) } } }
        item { Spacer(Modifier.height(12.dp)) }
    }
}

@Composable
private fun GradientCard(color: Color, content: @Composable ColumnScope.() -> Unit) {
    Card(colors = CardDefaults.cardColors(containerColor = color), shape = RoundedCornerShape(28.dp), modifier = Modifier.fillMaxWidth()) { Column(Modifier.padding(26.dp), verticalArrangement = Arrangement.spacedBy(8.dp), content = content) }
}

@Composable
private fun MetricCard(label: String, value: String, color: Color, modifier: Modifier = Modifier) {
    Card(modifier, colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = .55f))) { Column(Modifier.padding(vertical = 18.dp, horizontal = 8.dp), horizontalAlignment = Alignment.CenterHorizontally) { Icon(Icons.Default.Favorite, null, tint = color); Spacer(Modifier.height(7.dp)); Text(value, fontWeight = FontWeight.Black, fontSize = 18.sp, maxLines = 1); Text(label, color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 13.sp) } }
}

@Composable
private fun DailyPlanCard(metrics: QuitMetrics) {
    val target = 3
    val progress = (metrics.todayRecords.count { !it.didSmoke }.toFloat() / target).coerceIn(0f, 1f)
    Card(colors = CardDefaults.cardColors(containerColor = Color(0xFFE9ECFF))) { Column(Modifier.padding(20.dp)) { Text("今日计划", color = Purple, fontWeight = FontWeight.Bold); Spacer(Modifier.height(8.dp)); Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { Text("少吸 ${metrics.todayRecords.count { !it.didSmoke }} / $target 次", fontWeight = FontWeight.Bold, fontSize = 20.sp); Text(if (progress == 1f) "今日目标已完成" else "再少吸 ${target - metrics.todayRecords.count { !it.didSmoke }} 次", color = if (progress == 1f) Green else Purple) }; Spacer(Modifier.height(8.dp)); Slider(value = progress, onValueChange = {}, enabled = false) } }
}

@Composable
private fun HealthCard(metrics: QuitMetrics) {
    val hours = ((metrics.now - metrics.profile.quitAt).coerceAtLeast(0) / 3_600_000).toInt()
    val current = HealthMilestone.all.lastOrNull { hours >= it.hours } ?: HealthMilestone.all.first()
    val next = HealthMilestone.all.firstOrNull { hours < it.hours }
    Card(colors = CardDefaults.cardColors(containerColor = Color(0xFFE2F8EE))) { Column(Modifier.padding(20.dp)) { Text("健康里程碑", color = Teal, fontWeight = FontWeight.Bold); Text(current.title, fontWeight = FontWeight.Black, fontSize = 24.sp); Text(current.benefit, color = MaterialTheme.colorScheme.onSurfaceVariant); if (next != null) Text("下一阶段：${next.title} · 还需 ${next.hours - hours} 小时", color = Blue, fontWeight = FontWeight.SemiBold) } }
}
