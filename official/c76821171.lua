--ヴァルモニカの異神－ジュラルメ
--Duralume, Vaalmonican Heathen Hallow
--Ashaki
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),1,1)
	--Cannot be Link Summoned unless you have a Fairy Monster Card with 3 or more Resonance Counters in your Pendulum Zone
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(s.spcost)
	c:RegisterEffect(e0)
	--Destroy opponent's monsters up to the number of Resonance Counters in your Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--This card can make a 2nd and 3rd attack this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e2:SetCost(s.tripleatkcost)
	e2:SetTarget(s.tripleatktg)
	e2:SetOperation(s.tripleatkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VAALMONICA}
s.counter_list={COUNTER_RESONANCE}
s.listed_names={id}
function s.spcfilter(c)
	return c:IsFaceup() and c:IsOriginalRace(RACE_FAIRY) and c:GetCounter(COUNTER_RESONANCE)>=3
end
function s.spcost(e,c,tp,st)
	if (st&SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_PZONE,0,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	local ct=Duel.GetCounter(tp,1,0,COUNTER_RESONANCE)
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.tripleatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_COST)
end
function s.tripleatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local effs={e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK)}
		for _,eff in ipairs(effs) do
			if eff:GetValue()>=2 then
				return false
			end
		end
		return true
	end
end
function s.tripleatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--Can make a 2nd and 3rd attack this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(2)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end