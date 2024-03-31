--三日月の剣豪将軍
--Kengo Shogun of the Crescent Moon
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 1 "Masaki the Legendary Samurai General" + 1 "Hero of the Yeast"
	Fusion.AddProcMix(c,true,true,160201007,160305015)
	-- Destruction immunity
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.indescost)
	e1:SetOperation(s.indesop)
	c:RegisterEffect(e1)
end
function s.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		--Cannot be destroyed by opponent's Trap effects this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3012)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(function(e,te) return te:IsTrapEffect() and te:GetOwnerPlayer()==1-e:GetOwnerPlayer() end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end