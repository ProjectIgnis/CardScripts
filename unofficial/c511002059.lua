--No.91 サンダー・スパーク・ドラゴン
Duel.LoadCardScript("c84417082.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,5)
	c:EnableReviveLimit()
	--destroy1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32543380,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.AND(Cost.DetachFromSelf(3),Cost.HintSelectedEffect))
	e1:SetTarget(s.destg1)
	e1:SetOperation(s.desop1)
	c:RegisterEffect(e1)
	--destroy2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84417082,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.AND(Cost.DetachFromSelf(5),Cost.HintSelectedEffect))
	e2:SetTarget(s.destg2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
	--battle indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(s.indes)
	c:RegisterEffect(e3)
end
s.xyz_number=91
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0,nil)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.indes(e,c)
	return not c:IsSetCard(SET_NUMBER)
end
