--大逆転ＢＯＸ
--Reversal Box
--scripted by pyrQ
local s,id=GetID()
local COUNTER_REVERSAL_BOX=0x21b
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_REVERSAL_BOX)
	c:SetCounterLimit(COUNTER_REVERSAL_BOX,6)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn, during the Standby Phase: Roll a six-sided die and place counters on this card equal to the result (max. 6)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.countertg)
	e1:SetOperation(s.counterop)
	c:RegisterEffect(e1)
	--When a monster effect is activated on your opponent's field, or once per battle, during damage calculation, if an opponent's monster attacks: You can remove 1 counter from this card, then target 1 of those monsters; toss a coin and call it. If you call it right, you can Special Summon 1 monster that mentions "Dark Time Wizard" from your Deck, and if you do, until the end of this turn, change the targeted monster's ATK to 0, also its effects are negated
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2a:SetType(EFFECT_TYPE_QUICK_O)
	e2a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetCondition(s.coincon)
	e2a:SetCost(Cost.RemoveCounterFromSelf(COUNTER_REVERSAL_BOX,1))
	e2a:SetTarget(s.cointg)
	e2a:SetOperation(s.coinop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2b:SetCondition(function(e,tp,eg) return Duel.GetAttacker():IsControler(1-tp) end)
	e2b:SetCost(Cost.AND(Cost.RemoveCounterFromSelf(COUNTER_REVERSAL_BOX,1),Cost.SoftOncePerBattle(id)))
	c:RegisterEffect(e2b)
end
s.listed_names={CARD_DARK_TIME_WIZARD}
s.roll_dice=true
s.toss_coin=true
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,COUNTER_REVERSAL_BOX)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local die_roll=Duel.TossDice(tp,1)
		local ct=1
		if die_roll~=1 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			ct=Duel.AnnounceNumberRange(tp,1,die_roll)
		end
		c:AddCounter(COUNTER_REVERSAL_BOX,ct,true)
	end
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc,trig_ctrl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	return re:IsMonsterEffect() and trig_ctrl==1-tp and trig_loc==LOCATION_MZONE and re:GetHandler():IsRelateToEffect(re)
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local opp_card=e:GetCode()==EVENT_CHAINING and eg:GetFirst() or Duel.GetAttacker()
	if chk==0 then return opp_card:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(opp_card)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,opp_card,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,opp_card,1,tp,0)
end
function s.spfilter(c,e,tp)
	return c:ListsCode(CARD_DARK_TIME_WIZARD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CallCoin(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local tc=Duel.GetFirstTarget()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
			and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local c=e:GetHandler()
			--Until the end of this turn, change the targeted monster's ATK to 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			--Also its effects are negated
			tc:NegateEffects(c,RESET_PHASE|PHASE_END)
		end
	end
end