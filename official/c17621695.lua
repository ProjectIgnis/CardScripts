--糾罪都市－エニアポリス
--Enneapolis, the Sinquisition City
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Remove all Sinquisition Counters from your fiend, and if you do, inflict 900 damage to your opponent for each
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--Return any number of "Enneacraft" Pendulum Monster Cards you control to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
	c:RegisterEffect(e2)
	--Return to the hand, or place in your Pendulum Zone, 1 of your "Enneacraft" Pendulum Monsters that was flipped face-up during the Main Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thpztg)
	e3:SetOperation(s.thpzop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	--Keep track of "Enneacraft" Pendulum Monsters that were flipped face-up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_FLIP)
	e4:SetRange(LOCATION_FZONE)
	e4:SetLabelObject(e3)
	e4:SetCondition(function() return Duel.IsMainPhase() end)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ENNEACRAFT}
s.counter_list={COUNTER_SINQUISITION}
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetCounter(tp,1,0,COUNTER_SINQUISITION)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*900)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.HasCounter,tp,LOCATION_ONFIELD,0,nil,COUNTER_SINQUISITION)
	if #g==0 then return end
	local total_count=0
	for sc in g:Iter() do
		local sc_count=sc:GetCounter(COUNTER_SINQUISITION)
		if sc:RemoveCounter(tp,COUNTER_SINQUISITION,sc_count,REASON_EFFECT) then
			total_count=total_count+sc_count
		end
	end
	if total_count>0 then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Damage(p,total_count*900,REASON_EFFECT)
	end
end
function s.rthfilter(c)
	return c:IsSetCard(SET_ENNEACRAFT) and c:IsOriginalType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.rthfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.thpzfilter(c,tp)
	return c:IsSetCard(SET_ENNEACRAFT) and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and (c:IsAbleToHand() or (not c:IsForbidden() and Duel.CheckPendulumZones(tp)))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.thpzfilter,nil,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.thpztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():Filter(s.thpzfilter,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetTargetCard(g)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thpzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(s.thpzfilter,nil,tp)
	if #g==0 then return end
	local sc=nil
	if #g==1 then
		sc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		sc=g:Select(tp,1,1,nil,tp):GetFirst()
	end
	if not sc then return end
	Duel.HintSelection(sc)
	local b1=sc:IsAbleToHand()
	local b2=Duel.CheckPendulumZones(tp) and not sc:IsForbidden()
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,4)},
		{b2,aux.Stringid(id,5)})
	if op==1 then
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
	elseif op==2 then
		Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
