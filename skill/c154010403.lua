--Harpies' Last Will
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={18144506}
s.listed_series={0x64}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,4,nil,0x64) and Duel.GetFlagEffect(ep,id)==0 and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TO_HAND)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Add HFD
	local tc=Duel.CreateToken(tp,18144506)
	if tc then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end

