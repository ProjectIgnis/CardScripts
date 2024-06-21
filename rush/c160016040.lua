--トランザムヴェルグ・ライナック
--Transamuvelgr Rainac
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_TRANSAMU_RAINAC,160010025)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,900)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsMonster()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)<1 then return end
	local sg=Duel.GetOperatedGroup()
	--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(900)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	c:RegisterEffect(e1)
	local g2=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
	local ct=sg:FilterCount(s.cfilter,nil)
	if ct>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		for tc in g2:Iter() do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(-1000)
			e2:SetReset(RESETS_STANDARD_PHASE_END,2)
			tc:RegisterEffect(e2)
		end
	end
end