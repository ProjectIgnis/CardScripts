--アローザル・ハイドライブ・モナーク
--Rousing Hydradrive Monarch
--Scripted by The Razgriz
local s,id=GetID()
local ATTRIBUTES_WATER_FIRE_WIND=ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND
local COUNTER_HYDRADRIVE=0x577
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_HYDRADRIVE)
	--Link Summon procedure: 4 "Hydradrive" Link monsters
	Link.AddProcedure(c,s.matfilter,4,4)
	--Also treated as WATER/FIRE/WIND Attribute while face-up on field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(ATTRIBUTES_WATER_FIRE_WIND)
	c:RegisterEffect(e0)
	--Negate effects/0 ATK of all other monsters with same Attribute
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_DISABLE)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1a:SetTarget(function(e,c)	return c:IsAttribute(e:GetHandler():GetAttribute()) and c~=e:GetHandler() end)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1b:SetValue(0)
	c:RegisterEffect(e1b)
	--Players can only Normal/Special Summon monsters with the same Attribute as this card in Attack Position
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetCode(EFFECT_FORCE_NORMAL_SUMMON_POSITION)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(1,1)
	e2a:SetTarget(function(e,c,sump,sumtype,sumpos,targetp) return (c:GetAttribute()&e:GetHandler():GetAttribute())>0 end)
	e2a:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	c:RegisterEffect(e2b)
	--Place Hydradrive Counters when Special Summoned from the Extra Deck to your field
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e) local c=e:GetHandler() return c:IsSummonLocation(LOCATION_EXTRA) and c:GetControler()==e:GetHandlerPlayer() end)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	--During the Main Phase (Quick Effect): You can remove 1 Hydradrive Counter from this card; roll a six-sided die, and if your opponent controls a face-up monster(s) in their Monster Zone with an Attribute that corresponds to the result, 
	--send as many of those monsters to the GY as possible, and if you do, inflict damage to your opponent equal to the number of monsters sent to the GY x 500.
	--● 1: EARTH ● 2: WATER ● 3: FIRE ● 4: WIND ● 5: LIGHT ● 6: DARK
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DICE+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(Cost.RemoveCounterFromSelf(COUNTER_HYDRADRIVE,1))
	e4:SetCondition(function(e,tp) return e:GetHandler():GetCounter(COUNTER_HYDRADRIVE)>0 and Duel.IsMainPhase() and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end)
	e4:SetTarget(s.dicesendtogravetg)
	e4:SetOperation(s.dicesendtograveop)
	c:RegisterEffect(e4)
end
s.listed_series={0x577} --"Hydradrive" archetype
s.counter_place_list={COUNTER_HYDRADRIVE}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x577) and c:IsLinkMonster()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,4,0,COUNTER_HYDRADRIVE)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	   c:AddCounter(COUNTER_HYDRADRIVE,4)
	end
end
function s.dicesendtogravefilter(c,att)
	return c:IsAbleToGrave() and c:IsAttribute(att)
end
function s.dicesendtogravetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,sg,#sg,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,#sg*500)
end
function s.dicesendtograveop(e,tp,eg,ep,ev,re,r,rp)
	local dice=Duel.TossDice(tp,1)
	local att
	if dice==1 then att=ATTRIBUTE_EARTH end
	if dice==2 then att=ATTRIBUTE_WATER end
	if dice==3 then att=ATTRIBUTE_FIRE end
	if dice==4 then att=ATTRIBUTE_WIND end
	if dice==5 then att=ATTRIBUTE_LIGHT end
	if dice==6 then att=ATTRIBUTE_DARK end
	local g=Duel.GetMatchingGroup(s.dicesendtogravefilter,tp,0,LOCATION_ONFIELD,nil,att)
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		local dc=Duel.GetOperatedGroup()
		Duel.Damage(1-tp,#dc*500,REASON_EFFECT)
	end
end
