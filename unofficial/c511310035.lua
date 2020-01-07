--金色の魅惑の女王
--Golden Allure Queen
--Scripted by AlphaKretin
local s,id=GetID()
local CARD_ALLURE_PALACE=511310036
local SET_ALLURE_QUEEN=0x14
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),3,3)
	c:EnableReviveLimit()
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2204038,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.indcon)
	e2:SetOperation(s.indop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(s.indcon2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ALLURE_QUEEN}
s.listed_names={CARD_ALLURE_PALACE}
function s.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(aux.FilterFaceupFunction(Card.IsSetCard,SET_ALLURE_QUEEN),nil)
	return g:GetSum(Card.GetAttack)
end
function s.tgfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(SET_ALLURE_QUEEN)
end
s.fzfilter=aux.FilterFaceupFunction(Card.IsCode,CARD_ALLURE_PALACE)
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.tgfilter,1,nil,tp)
	if not tg or #tg<1 then return false end
	tg:KeepAlive()
	e:SetLabelObject(tg)
	return rp~=tp and Duel.IsExistingMatchingCard(s.fzfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.tgfilter,1,nil,tp)
	if not tg or #tg<1 then return false end
	tg:KeepAlive()
	e:SetLabelObject(tg)
	return Duel.IsExistingMatchingCard(s.fzfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetLabelObject()
	tg:Filter(Card.IsRelateToEffect,nil,e)
	for tc in aux.Next(tg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(63941210,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
	end
	tg:DeleteGroup()
end