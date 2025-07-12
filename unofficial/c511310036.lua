--魅惑の宮殿
--Allure Palace
--Scripted by AlphaKretin
local s,id=GetID()
local EFFECT_ALLURE_PALACE_ANIME=511310036
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--All "Allure Queen" monsters you control gain 500 ATK/DEF
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ALLURE_QUEEN))
	e1a:SetValue(500)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--Also, you can activate their effects that activate by sending themselves to the GY during your Main Phase
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetCode(EFFECT_ALLURE_PALACE_ANIME)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetTargetRange(1,0)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_ADJUST)
	e2b:SetRange(LOCATION_FZONE)
	e2b:SetOperation(s.regop)
	c:RegisterEffect(e2b)
	--Special Summon to your opponent's field, 1 monster with the same name as an "Allure Queen" monster that was Normal or Special Summoned to your field
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,0))
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetCondition(s.spcon)
	e3a:SetTarget(s.sptg)
	e3a:SetOperation(s.spop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_ALLURE_QUEEN}
function s.regop(e,tp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_ALLURE_QUEEN),tp,LOCATION_MZONE,0,nil):Match(aux.NOT(Card.HasFlagEffect),nil,id)
	if #g==0 then return end
	for allure_card in g:Iter() do
		local effs={allure_card:GetOwnEffects()}
		for _,eff in ipairs(effs) do
			if eff:HasSelfToGraveCost() and eff:GetCode()&(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)>0 then
				allure_card:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
				local condition=eff:GetCondition()
				--Ignition Effect version of the "Allure Queen" monster's Trigger Effect
				local e1=eff:Clone()
				e1:SetType(EFFECT_TYPE_IGNITION)
				e1:SetCode(0)
				e1:SetCondition(function(e,tp) return Duel.IsPlayerAffectedByEffect(tp,EFFECT_ALLURE_PALACE_ANIME) and condition(e,tp) end)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				allure_card:RegisterEffect(e1)
			end
		end
	end
end
function s.spconfilter(c,tp)
	return c:IsSetCard(SET_ALLURE_QUEEN) and c:IsControler(tp) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.spconfilter,nil,tp):Match(s.tgfilter,nil,e,tp)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and g:IsContains(chkc) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return #g>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	local tg=nil
	if #g==1 then
		tg=g
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tg=g:Select(tp,1,1,nil)
	end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
		if #g>0 then
			 Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end