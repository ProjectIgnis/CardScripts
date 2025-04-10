--落魂
--Otoshidamashi
--Scripted by Kohana Sonogami
local COUNTER_OTOSHIDAMASHI=0x59
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_OTOSHIDAMASHI,LOCATION_MZONE)
	--Your opponent's monster cannot target this card for attacks while you control a non-Tuner monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atklm)
	e1:SetValue(aux.imval2)
	c:RegisterEffect(e1)
	--Special Summon "Otoshidamashi Tokens" equal to the number of "Otoshidamashi Counters" on this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
s.listed_names={14957441} --"Otoshidamashi Tokens"
function s.atkfilter(c)
	return c:IsFacedown() or (c:IsFaceup() and not c:IsType(TYPE_TUNER))
end
function s.atklm(e)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsMonster() and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(COUNTER_OTOSHIDAMASHI,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:AddCounter(COUNTER_OTOSHIDAMASHI,1) and ft>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		Duel.BreakEffect()
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local ct=c:GetCounter(COUNTER_OTOSHIDAMASHI)
		if ct>ft then ct=ft end
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
			ct=Duel.AnnounceNumberRange(tp,1,ct)
		end
		for i=1,ct do
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
			e1:SetValue(c:GetCounter(COUNTER_OTOSHIDAMASHI))
			token:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK)
			e2:SetValue((c:GetCounter(COUNTER_OTOSHIDAMASHI)+1)*500)
			e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
			token:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_DEFENSE)
			e3:SetValue((c:GetCounter(COUNTER_OTOSHIDAMASHI)+1)*500)
			e3:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
			token:RegisterEffect(e3,true)
		end
		Duel.SpecialSummonComplete()
	end
end