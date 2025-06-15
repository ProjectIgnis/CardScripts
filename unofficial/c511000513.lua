--Ｎｏ．７７ ザ・セブン・シンズ (Manga)
--Number 77: The Seven Sins (Manga)
Duel.LoadCardScript("c62541668.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 12 monsters
	Xyz.AddProcedure(c,nil,12,2)
	--Cannot be destroyed by battle, except by "Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Destroy monsters your opponent controls, then attach them to this card as Xyz Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.desatchtg)
	e2:SetOperation(s.desatchop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--If this card would be banished, you can detach 1 material from this card instead
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NUMBER}
s.xyz_number=77
function s.desatchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desatchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local sg=g:Filter(aux.NOT(Card.IsLocation),c,LOCATION_MZONE)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Overlay(c,sg)
		end
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDestination()==LOCATION_REMOVED and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
		return true
	else return false end
end