--モザイク・マンティコア
local s,id=GetID()
function s.initial_effect(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.spfilter(c,e,tp,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_SUMMON) and c:GetReasonCard()==rc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetHandler():GetMaterial():Filter(s.spfilter,nil,e,tp,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local c=e:GetHandler()
	local g=c:GetMaterial():Filter(s.spfilter,nil,e,tp,c)
	if #g>0 then
		if #g>ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			g=g:Select(tp,ft,ft,nil)
		end
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		Duel.SpecialSummonComplete()
	end
end
