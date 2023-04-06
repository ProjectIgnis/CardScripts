--新世壊＝アムリターラ
--Pristine Planets Amritara
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.effcon)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_VISAS_STARFROST}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_VISAS_STARFROST),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsFaceup()
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.cfilter,nil,tp)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
	local b2=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_TUNER),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and g:IsExists(Card.IsAttackAbove,1,nil,1)
	local b3=g:IsExists(Card.IsAbleToDeck,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	local b4=c:IsAbleToDeck() and Duel.IsExistingMatchingCard(aux.AND(Card.IsFieldSpell,Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 or b4 end
	Duel.SetTargetCard(g)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)},
		{b4,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	elseif op==3 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif op==4 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local op=e:GetLabel()
	if #g==0 and op~=4 then return end
	--Special Summon 1 of them in Defense Position
	if op==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	--1 Tuner on the field gains ATK
	elseif op==2 and g:IsExists(Card.IsAttackAbove,1,nil,1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local tuner=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsType,TYPE_TUNER),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		if tuner then
			Duel.HintSelection(tuner,true)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tc=g:FilterSelect(tp,Card.IsAttackAbove,1,1,nil,1):GetFirst()
			Duel.HintSelection(tc,true)
			--Increase ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetAttack()/2)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tuner:RegisterEffect(e1)
		end
	--Shuffle 1 of them into the Deck and draw 1 card
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tc=g:FilterSelect(tp,Card.IsAbleToDeck,1,1,nil):GetFirst()
		if tc then
			Duel.HintSelection(tc,true)
			if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA) then
				if tc:IsLocation(LOCATION_DECK) then
					Duel.ShuffleDeck(tp)
				end
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	--Shuffle this card into the Deck and add 1 Field Spell from your GY to your hand
	elseif op==4 and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local th=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFieldSpell,Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,1,nil)
		if #th>0 then
			Duel.SendtoHand(th,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,th)
		end
	end
end