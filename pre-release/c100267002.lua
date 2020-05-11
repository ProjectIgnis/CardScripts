--ハーピィ・レディ・SC
--Harpie Lady Scratch Clash
--Logical Nonsense

local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Synchro summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	--Name becomes "Harpie Lady" while on field or in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_HARPIE_LADY)
	c:RegisterEffect(e1)
	--Return opponent's monster or player's "Harpie" monster to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
	--Lists "Harpie" archetype
s.listed_series={0x64}
	--Specifically lists itself and "Harpie Lady"
s.listed_names={id,CARD_HARPIE_LADY}

	--Can treat a "Harpie" monster as a tuner
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x64,scard,sumtype,tp)
end
	--Check for opponent's monster or player's "Harpie" monster
function s.filter(c,tp)
	return c:IsAbleToHand() and (c:IsControler(1-tp) or (c:IsSetCard(0x64)))
end
	--If a spell/trap card or effect activated
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
	--Return 1 of opponent's monster or player's "Harpie" monster to hand
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
