--古の呪文
--Ancient Chant
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Add RA and Extra Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Banish GY and Original atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.checktribute)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RA}
function s.filter(c)
	return c:IsCode(CARD_RA) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	--Extra Tribute Summon
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+1)==0
end
function s.checktribute(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetOperation(s.atkboost)
	Duel.RegisterEffect(e1,0)
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
end
function s.atkboost(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetHandler()
	if tc:IsTributeSummoned() and tc:IsCode(CARD_RA) then
		local g=tc:GetMaterial()
		local atk=0
		local def=0
		for gc in aux.Next(g) do
			atk=atk+gc:GetBaseAttack()
			def=def+gc:GetBaseDefense()
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(def)
		tc:RegisterEffect(e2)
	end
end