--カオス・フォーム
--Chaos Form
local s,id=GetID()
function s.initial_effect(c)
	local e1=aux.AddRitualProcEqual(c,s.ritualfil,nil,nil,s.extrafil)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_BLUEEYES_W_DRAGON}
function s.ritualfil(c)
	return (c:IsSetCard(0xcf) or c:IsSetCard(0x1048)) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:GetLevel()>0 and c:IsCode(CARD_DARK_MAGICIAN,CARD_BLUEEYES_W_DRAGON)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
