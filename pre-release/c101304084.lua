--JP name
--VIP Whale
--scripted by pyrQ
local s,id=GetID()
local COUNTER_VIP=0x21a
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_VIP)
	--You can Tribute additional monsters when you Tribute Summon this card face-up
	aux.AddNormalSummonProcedure(c,true,true,2,12,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	--If this card is Tribute Summoned: You can place VIP Counters on this card equal to the number of monsters Tributed for its Tribute Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsTributeSummoned() end)
	e1:SetTarget(s.countertg)
	e1:SetOperation(s.counterop)
	c:RegisterEffect(e1)
	--When your opponent activates a card or effect (Quick Effect): You can remove 1 VIP Counter from this card; toss a coin and call it. If you call it right, negate that effect. If you call it wrong, this card's original ATK becomes halved until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e2:SetCost(Cost.RemoveCounterFromSelf(COUNTER_VIP,1))
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_VIP}
s.toss_coin=true
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local trib_monsters_count=c:GetMaterialCount()
	if chk==0 then return trib_monsters_count>0 and c:IsCanAddCounter(COUNTER_VIP,trib_monsters_count) end
	e:SetLabel(trib_monsters_count)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,trib_monsters_count,tp,COUNTER_VIP)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(COUNTER_VIP,e:GetLabel())
	end
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CallCoin(tp) then
		--If you call it right, negate that effect
		Duel.NegateEffect(ev)
	else
		--If you call it wrong, this card's original ATK becomes halved until the end of this turn
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--This card's original ATK becomes halved until the end of this turn
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(c:GetBaseAttack()/2)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end