--Japanese name
--Mimighoul Armor
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--FLIP: Apply these effects in sequence
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Special Summon this card to your opponent's field in face-down Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MIMIGHOUL}
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:IsAbleToChangeControler() then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	--This turn, "Mimighoul" monsters cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MIMIGHOUL))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,1,aux.Stringid(id,2))
	--Give control of this card to your opponent
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.GetControl(c,1-tp)
	end
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp))
		or (Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	else
		op=(b1 and 1) or (b2 and 2) or 1
	end
	if op==1 then
		if Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)==0 then return end
		Duel.ConfirmCards(tp,c)
	elseif op==2 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end