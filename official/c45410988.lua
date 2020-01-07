--レッドアイズ・トランスマイグレーション
--Red-Eyes Transmigration
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.AddProcGreater(c,s.ritualfil,8,nil,s.extrafil)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_series={0x3b}
s.fit_monster={19025379} --should be removed in hardcode overhaul
s.listed_names={19025379}
function s.ritualfil(c)
	return c:IsCode(19025379) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:HasLevel() and c:IsSetCard(0x3b)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end