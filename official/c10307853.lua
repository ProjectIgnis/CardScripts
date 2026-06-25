--護石の作庭
--Protective Stone Gardenscaping
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--While you have 5 cards in your Spell & Trap Zone, any battle damage a player takes is halved, also once per turn, you can activate 1 Continuous Trap Card the turn it was Set
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetTargetRange(1,1)
	e1a:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_STZONE,0)==5 end)
	e1a:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetDescription(aux.Stringid(id,0))
	e1b:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1b:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1b:SetTargetRange(LOCATION_SZONE,0)
	e1b:SetCountLimit(1)
	c:RegisterEffect(e1b)
	--During the Standby Phase: You can reveal 5 Continuous Traps with different names from your Deck, your opponent randomly picks 1 for you to Set on your field, also shuffle the rest into the Deck. You can only use this effect of "Protective Stone Gardenscaping" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.IsStandbyPhase() end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	e2:SetHintTiming(TIMING_STANDBY_PHASE)
	c:RegisterEffect(e2)
end
function s.setfilter(c)
	return c:IsContinuousTrap() and c:IsSSetable() and not c:IsPublic()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>=5 and g:GetClassCount(Card.GetCode)>=5 end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #g<5 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,5,5,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,rg)
	Duel.ShuffleDeck(tp)
	local sg=rg:RandomSelect(1-tp,1)
	if #sg>0 then
		Duel.DisableShuffleCheck()
		Duel.SSet(tp,sg,tp,false)
	end
end