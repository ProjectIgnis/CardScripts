--Masked Tribute
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_names={48948935,86569121,13676474}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	if Duel.GetFlagEffect(ep,id)>1 then return end 
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_HAND,0,1,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--tpd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Masked Tribute
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoDeck(sg,tp,2,REASON_EFFECT) then
		local table={86569121,13676474}
		local mask=table[Duel.GetRandomNumber(1,#table)]   
		local tc=Duel.CreateToken(tp,mask)
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_DEFENSE,true)
		end
	end
	 --Cannot Summon/Set monsters besides Gardius
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(s.actlimit)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e4,tp)
end
function s.actlimit(e,c)
	return not c:IsCode(48948935)
end

