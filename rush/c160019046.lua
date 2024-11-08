--メタリオン・アルマロスター
--Metarion Armarostar
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_IMAGINARY_ACTOR,160019001)
	--reveal face-down cards and destroy spells
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.revtg)
	e1:SetOperation(s.revop)
	c:RegisterEffect(e1)
	--Take control of an opponent's fairy monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.ctrltg)
	e2:SetOperation(s.ctrlop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanChangePosition() end
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)==0 then return end
	--Effect
	local sg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	Duel.ConfirmCards(tp,sg)
	local dg=sg:Filter(Card.IsSpell,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.ctrlfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and not c:IsType(TYPE_MAXIMUM) and c:IsControlerCanBeChanged(true)
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local dg=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #dg>0 then
		Duel.HintSelection(dg)
		Duel.GetControl(dg,tp)
	end
end