--Ｄ－フォース
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)	
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)	
	--Cannot draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetRange(LOCATION_DECK)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.drcon1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_DRAW_COUNT)
	e3:SetRange(LOCATION_DECK)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.drcon2)
	e3:SetValue(0)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
		c:ReverseInDeck()
	end
end
function s.drcon1(e)
	return s.drcon2(e) and Duel.GetCurrentPhase()==PHASE_DRAW
end
function s.drcon2(e)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(e:GetHandlerPlayer(),1)
	return g:GetFirst()==c and c:IsFaceup() and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
