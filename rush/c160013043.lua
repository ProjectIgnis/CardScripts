--魔導騎士－セブンス・チャリオット
--Sevens Chariot the Magical Knight
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_SEVENS_ROAD_MAGICIAN,160013013)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- Destruction immunity
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(s.cost)
	e2:SetOperation(s.indesop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_STZONE,LOCATION_STZONE,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atkval=Duel.GetMatchingGroupCount(nil,tp,LOCATION_STZONE,LOCATION_STZONE,nil)*500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atkval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- Effect (cannot be destroyed by opponent's trap effects)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3060)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(function(e,te)return te:GetOwnerPlayer()~=e:GetOwnerPlayer()end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,0,nil)
		local g2=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			sg=g2:Select(tp,1,#g,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg,true)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
