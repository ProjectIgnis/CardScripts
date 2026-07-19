--光器の瀑布
--Sennet Cataract
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Choose opponent's Main Monster Zones equal to the number of Normal Monsters and "Sennet" Ritual Monsters you control; negate the first monster effect activated in each of those zones that resolves this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If the total ATK of all Normal Monster Cards you control is more than 3000: You can banish this card from your GY, then target 1 monster your opponent controls; send it to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tgcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SENNET}
function s.ctfilter(c)
	return (c:IsType(TYPE_NORMAL) or (c:IsSetCard(SET_SENNET) and c:IsRitualMonster())) and c:IsFaceup()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 end
	ct=math.min(ct,5)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local selected_zones=Duel.SelectFieldZone(tp,ct,0,LOCATION_MZONE,ZONES_EMZ<<16)
	Duel.Hint(HINT_ZONE,tp,selected_zones)
	e:GetChainData().selected_zones=selected_zones
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local selected_zones=e:GetChainData().selected_zones
	Duel.Hint(HINT_ZONE,tp,selected_zones)
	--Negate the first monster effect activated in each of those zones that resolves this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Chain.IsTriggeringLocation(ev,LOCATION_MMZONE) and Chain.IsTriggeringControler(ev,1-tp)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local zone=1<<(Chain.GetTriggeringSequence(ev)+16)
		if (selected_zones&zone)==0 then return end
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
		selected_zones=selected_zones&~zone
		if selected_zones==0 then e:Reset() end
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsOriginalType,TYPE_NORMAL),tp,LOCATION_ONFIELD,0,nil):GetSum(Card.GetAttack)>3000
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToGrave() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end