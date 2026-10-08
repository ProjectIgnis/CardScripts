--カウンターマジック「攻撃の無力化」
--Counter Spell "Negate Attack"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--During the Battle Phase: Activate 1 of these effects;
	--● When an opponent's monster declares an attack while they control more monsters than you do: Negate the attack, then end the Battle Phase
	--● When your opponent activates a monster effect: Negate that effect, and if you do, destroy that monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsBattlePhase()
	end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--When you draw for your normal draw in your Draw Phase: You can banish this card from your GY; Special Summon 1 monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● When an opponent's monster declares an attack while they control more monsters than you do: Negate the attack, then end the Battle Phase
	local option_1=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and Duel.GetAttacker():IsControler(1-tp)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	--● When your opponent activates a monster effect: Negate that effect, and if you do, destroy that monster
	local event_check,_,event_player,event_value,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local option_2=event_check and event_player==1-tp and event_reff:IsMonsterEffect() and Chain.IsDisablable(event_value)
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)})
	local chain_data=e:GetChainData()
	chain_data.choice=choice
	if choice==1 then
		--● When an opponent's monster declares an attack while they control more monsters than you do: Negate the attack, then end the Battle Phase
		e:SetCategory(0)
	elseif choice==2 then
		--● When your opponent activates a monster effect: Negate that effect, and if you do, destroy that monster
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
		local event_rcard=event_reff:GetHandler()
		chain_data.event_value=event_value
		chain_data.event_rcard=event_rcard
		chain_data.event_reff=event_reff
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,event_rcard,1,tp,0)
		if event_rcard:IsDestructable() and event_rcard:IsRelateToEffect(event_reff) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,event_rcard,1,tp,0)
		end
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local chain_data=e:GetChainData()
	if chain_data.choice==1 then
		--● When an opponent's monster declares an attack while they control more monsters than you do: Negate the attack, then end the Battle Phase
		if Duel.NegateAttack() then
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
		end
	elseif chain_data.choice==2 then
		--● When your opponent activates a monster effect: Negate that effect, and if you do, destroy that monster
		local event_value=chain_data.event_value
		local event_rcard=chain_data.event_rcard
		local event_reff=chain_data.event_reff
		if Duel.NegateEffect(event_value) and event_rcard:IsRelateToEffect(event_reff) then
			Duel.Destroy(event_rcard,REASON_EFFECT)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and (r&REASON_RULE)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,1,nil,e,0,tp,false,false)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end