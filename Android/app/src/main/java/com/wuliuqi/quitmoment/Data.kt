package com.wuliuqi.quitmoment

import android.content.Context
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.PrimaryKey
import kotlinx.coroutines.flow.Flow

@Entity(tableName = "quit_profile")
data class QuitProfileEntity(
    @PrimaryKey
    val id: Int = 1,
    val cigarettesPerDay: Int = 10,
    val packPrice: Double = 20.0,
    val cigarettesPerPack: Int = 20,
    val smokingYears: Int = 5,
    val tarMilligramsPerCigarette: Double = 10.0,
    val quitAt: Long = System.currentTimeMillis(),
    val highRiskScenes: String = ""
)

@Entity(tableName = "craving_records")
data class CravingRecordEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val createdAt: Long = System.currentTimeMillis(),
    val intensity: Int = 5,
    val trigger: String = "饭后",
    val mood: String = "平静",
    val note: String = "",
    val copingMethod: String = "",
    val didSmoke: Boolean = false,
    val cigaretteCount: Int = 0
)

@Dao
interface JieKeDao {
    @Query("SELECT * FROM quit_profile WHERE id = 1")
    fun observeProfile(): Flow<QuitProfileEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun saveProfile(profile: QuitProfileEntity)

    @Query("SELECT * FROM craving_records ORDER BY createdAt DESC")
    fun observeRecords(): Flow<List<CravingRecordEntity>>

    @Insert
    suspend fun addRecord(record: CravingRecordEntity)

    @Query("DELETE FROM craving_records WHERE id = :id")
    suspend fun deleteRecord(id: Long)
}

@Database(entities = [QuitProfileEntity::class, CravingRecordEntity::class], version = 1, exportSchema = false)
abstract class JieKeDatabase : RoomDatabase() {
    abstract fun dao(): JieKeDao

    companion object {
        fun create(context: Context): JieKeDatabase = Room.databaseBuilder(
            context.applicationContext,
            JieKeDatabase::class.java,
            "jieke.db"
        ).fallbackToDestructiveMigration().build()
    }
}

class JieKeRepository(context: Context) {
    private val dao = JieKeDatabase.create(context).dao()
    val profile = dao.observeProfile()
    val records = dao.observeRecords()

    suspend fun saveProfile(profile: QuitProfileEntity) = dao.saveProfile(profile)
    suspend fun addRecord(record: CravingRecordEntity) = dao.addRecord(record)
    suspend fun deleteRecord(id: Long) = dao.deleteRecord(id)
}
