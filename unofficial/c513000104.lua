--パワー・ウォール (Anime)
--Power Wall (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(tp)
	if dam<=0 or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local gc=0
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==1 then
		gc=1
	else
		local t={}
		local l=1
		while dam>0 and ct>0 do
			dam=dam-100
			ct=ct-1
			t[l]=l
			l=l+1
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		gc=Duel.AnnounceNumber(tp,table.unpack(t))
	end
	Duel.DiscardDeck(tp,gc,REASON_EFFECT)
	local val=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if val>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.damop)
		e1:SetLabel(val*100)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=ev-e:GetLabel()
	if dam<0 then dam=0 end
	Duel.ChangeBattleDamage(tp,dam)
end