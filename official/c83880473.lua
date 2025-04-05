--War Rock Spirit
--War Rock Spirit
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_WAR_ROCK}
--Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and aux.StatChangeDamageStepCondition()
end
function s.filter(c,e,tp,pos)
	return c:IsSetCard(SET_WAR_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,pos)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	local atk=Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,POS_FACEUP_ATTACK)
	local def=Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,POS_FACEUP_DEFENSE)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (atk or def) end
	local choice=-1
	local pos=0
	if atk and def then
		choice=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif atk then
		choice=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif def then
		choice=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if choice==0 then pos=POS_FACEUP_ATTACK
	elseif choice==1 then pos=POS_FACEUP_DEFENSE end
	e:SetLabel(choice)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,pos)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local choice=e:GetLabel()
		--Attack Position
		if choice==0 then 
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			--Negate its effects
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e2)
			--Cannot attack directly
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e3:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e3)
		--Defense Position
		elseif choice==1 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e4:SetTargetRange(LOCATION_MZONE,0)
			e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_WAR_ROCK))
			e4:SetValue(s.indct)
			e4:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e4,tp)
		end
	end
end
function s.indct(e,re,r)
	if (r&REASON_BATTLE)>0 then
		return 1
	else return 0 end
end