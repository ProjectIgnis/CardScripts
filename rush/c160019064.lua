--第六感
--Sixth Sense (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.roll_dice=true
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local t={}
	local i=1
	local p=1
	for i=1,6 do t[i]=i end
	local a1=Duel.AnnounceNumber(tp,table.unpack(t))
	for i=1,6 do
		if a1~=i then t[p]=i p=p+1 end
	end
	t[p]=nil
	local a2=Duel.AnnounceNumber(tp,table.unpack(t))
	local dc=Duel.TossDice(1-tp,1)
	if dc==a1 or dc==a2 then
		Duel.Draw(tp,dc,REASON_EFFECT)
	else
		Duel.DiscardDeck(tp,dc,REASON_EFFECT)
	end
end