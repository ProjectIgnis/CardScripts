--オッドアイズ・アドベント
local s,id=GetID()
function s.initial_effect(c)
	aux.AddRitualProcGreater(c,s.ritualfil,nil,s.extrafil,s.extraop,s.forcedgroup,nil,LOCATION_HAND+LOCATION_GRAVE):SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
end
function s.ritualfil(c)
	return c:IsRace(RACE_DRAGON) and c:IsRitualMonster()
end
function s.exfilter0(c)
	return c:IsSetCard(0x99) and c:GetLevel()>=1 and c:IsAbleToGrave()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
		return Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_EXTRA,0,nil)
	end
	return Group.CreateGroup()
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.forcedgroup(c,e,tp)
	return (c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD)) or (c:IsSetCard(0x99) and c:IsLocation(LOCATION_EXTRA))
end
