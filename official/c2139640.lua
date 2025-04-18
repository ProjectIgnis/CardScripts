--あまびえさん
--Amabie
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Make each player gain 300 LP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return Duel.IsPhase(PHASE_MAIN1) and not Duel.CheckPhaseActivity() end)
	e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)if chk==0 then return not e:GetHandler():IsPublic()end end)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,300)end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Recover(tp,300,REASON_EFFECT)
		Duel.Recover(1-tp,300,REASON_EFFECT)
	end)
	c:RegisterEffect(e1)
end