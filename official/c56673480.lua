--ドン・サウザンドの契約
--Contract with Don Thousand
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: Both players lose 1000 LP, and if they do, each draws 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	--All cards that are drawn while this card's effect is applied must remain revealed
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_DRAW)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetCondition(s.drop)
	e2a:SetLabelObject(g)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_PUBLIC)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2b:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2b:SetTarget(function(e,c) return g:IsContains(c) and c:HasFlagEffect(id+1) end)
	c:RegisterEffect(e2b)
	--While a player's Spell Card in their hand is revealed by this effect, that player cannot Normal Summon/Set monsters
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3a:SetCode(EFFECT_CANNOT_SUMMON)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetTargetRange(1,0)
	e3a:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.cannotsumfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil,g) end)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3b)
	local e3c=e3a:Clone()
	e3c:SetTargetRange(0,1)
	e3c:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.cannotsumfilter,e:GetHandlerPlayer(),0,LOCATION_HAND,1,nil,g) end)
	c:RegisterEffect(e3c)
	local e3d=e3c:Clone()
	e3d:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3d)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,Duel.GetLP(tp)-1000)
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)-1000)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pg=e:GetLabelObject()
	if not c:HasFlagEffect(id) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_DISABLE,0,1)
		pg:Clear()
	end
	for dc in eg:Iter() do
		pg:AddCard(dc)
		dc:RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD,0,1)
	end
end
function s.cannotsumfilter(c,pg)
	return c:IsPublic() and c:IsSpell() and pg:IsContains(c) and c:HasFlagEffect(id+1)
end