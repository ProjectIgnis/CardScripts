--絶火の祆威
--Wisprath Magistus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 "Magistus" or Spellcaster monster you control and 1 face-up monster your opponent controls; equip that opponent's face-up monster to your monster as an Equip Spell that gives it 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.equiptg)
	e1:SetOperation(s.equipop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your GY: You can target 1 Fusion, Synchro, Xyz, or Link Monster in your GY; shuffle both it and this card into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MAGISTUS}
function s.eqpmonsterfilter(c)
	return (c:IsSetCard(SET_MAGISTUS) or c:IsRace(RACE_SPELLCASTER)) and c:IsFaceup()
end
function s.eqpcardfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToChangeControler() and c:CheckUniqueOnField(tp)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetControler)==2
end
function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local available_stzones=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then available_stzones=available_stzones-1 end
	if chkc then return false end
	if chk==0 then return available_stzones>0
		and Duel.IsExistingTarget(s.eqpmonsterfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.eqpcardfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	local g=Duel.GetTargetGroup(s.eqpmonsterfilter,tp,LOCATION_MZONE,0,nil)+Duel.GetTargetGroup(s.eqpcardfilter,tp,0,LOCATION_MZONE,nil,tp)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local chain_data=e:GetChainData()
	chain_data.your_monster=tg:Filter(Card.IsControler,nil,tp):GetFirst()
	chain_data.oppo_monster=tg:Filter(Card.IsControler,nil,1-tp):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,chain_data.oppo_monster,1,tp,0)
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
	local chain_data=e:GetChainData()
	local your_monster=chain_data.your_monster
	local oppo_monster=chain_data.oppo_monster
	if not (oppo_monster:IsRelateToEffect(e) and oppo_monster:IsControler(1-tp) and oppo_monster:IsFaceup()) then return end
	if your_monster:IsRelateToEffect(e) and your_monster:IsControler(tp) and your_monster:IsFaceup()
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.Equip(tp,oppo_monster,your_monster) then
		--Equip limit
		local e0=Effect.CreateEffect(oppo_monster)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetValue(function(e,c) return c==your_monster end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		oppo_monster:RegisterEffect(e0)
		--Equip that opponent's face-up monster to your monster as an Equip Spell that gives it 500 ATK
		local e1=Effect.CreateEffect(oppo_monster)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		oppo_monster:RegisterEffect(e1)
	else
		Duel.SendtoGrave(oppo_monster,REASON_RULE,nil,PLAYER_NONE)
	end
end
function s.toextrafilter(c)
	return c:IsType(TYPE_EXTRA) and c:IsAbleToExtra()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.toextrafilter() end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck()
		and Duel.IsExistingTarget(s.toextrafilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.toextrafilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end