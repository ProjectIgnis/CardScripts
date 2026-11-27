--炎の平原を駆け抜ける百獣の王
--The King of Beasts that Rises from the Valley of Flames
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnableCheckReincarnation(c)
	--Link Summon procedure: 3 FIRE Effect Monsters
	Link.AddProcedure(c,s.matfilter,3,3)
	--Face-up monsters on the field become FIRE
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e1)
	--During the Main Phase, if this card was Link Summoned using "Salamangreat Heatleo" (Quick Effect): You can target 1 card your opponent controls; shuffle it into the Deck, then you can make the ATK of 1 FIRE monster your opponent controls become the ATK of 1 monster in your GY. You can only use this effect of "The King of Beasts that Rises from the Valley of Flames" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_names={41463181} --"Salamangreat Heatleo"
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE,scard,sumtype,tp) and c:IsType(TYPE_EFFECT,scard,sumtype,tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase() and c:IsReincarnationSummoned() and c:IsLinkSummoned()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
end
function s.atkfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetAttack())
end
function s.gyfilter(c,atk)
	return c:IsMonster() and not c:IsAttack(atk)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local oppc=Duel.SelectMatchingCard(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		if not oppc then return end
		Duel.HintSelection(oppc)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local gyc=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,oppc:GetAttack()):GetFirst()
		if not gyc then return end
		Duel.HintSelection(gyc)
		Duel.BreakEffect()
		--Then you can make the ATK of 1 FIRE monster your opponent controls become the ATK of 1 monster in your GY
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(gyc:GetAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		oppc:RegisterEffect(e1)
	end
end