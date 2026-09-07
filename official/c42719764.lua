--サモンショック
--Summon Shock
local s,id=GetID()
local COUNTER_SUMMON=0x148
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SUMMON)
	c:SetCounterLimit(COUNTER_SUMMON,4)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_STANDBY_PHASE)
	c:RegisterEffect(e0)
	--Each time a monster(s) is Normal or Special Summoned, place 1 Summon Counter on this card (max. 4)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetOperation(s.counterop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If the 4th Summon Counter is placed on this card: Remove all Summon Counters from this card, and if you do, send all monsters on the field to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_SUMMON}
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:AddCounter(COUNTER_SUMMON,1) and c:GetCounter(COUNTER_SUMMON)==4 then
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,0,0,tp,0)
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if c:IsRelateToEffect(e) and c:RemoveCounter(tp,COUNTER_SUMMON,c:GetCounter(COUNTER_SUMMON),REASON_EFFECT)
		and c:GetCounter(COUNTER_SUMMON)==0 and #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end