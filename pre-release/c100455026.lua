--ウィッチクラフト・ピューピルズ
--Witchcrafter Pupils
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Witchcrafter" monster + 1 Spellcaster monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_WITCHCRAFTER),aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER))
	--During the Main or Battle Phase (Quick Effect): You can activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function() return Duel.IsMainPhase() or Duel.IsBattlePhase() end)
	e1:SetCost(Cost.Choice(
			--● Add 1 "Witchcrafter" Spell from your Deck to your hand
			{aux.TRUE,aux.Stringid(id,2),function(e,tp) return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end},
			--● Reveal 1 "Witchcrafter" Normal or Quick-Play Spell in your hand; apply that Spell's activation effect
			{Cost.Reveal(s.revealfilter,nil,1,1,function(e,tp,og) e:SetLabelObject(og) end),aux.Stringid(id,3),nil}
		)
	)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--During your End Phase: You can return 1 of your banished "Witchcrafter" cards to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.rtgtg)
	e2:SetOperation(s.rtgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WITCHCRAFTER}
s.material_setcode=SET_WITCHCRAFTER
function s.thfilter(c)
	return c:IsSetCard(SET_WITCHCRAFTER) and c:IsSpell() and c:IsAbleToHand()
end
function s.revealfilter(c)
	return c:IsSetCard(SET_WITCHCRAFTER) and (c:IsNormalSpell() or c:IsQuickPlaySpell())
		and c:CheckActivateEffect(true,true,false)~=nil
		and c:CheckActivateEffect(true,true,false):GetOperation()~=nil
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=e:GetLabel()
	if op==1 then
		--● Add 1 "Witchcrafter" Spell from your Deck to your hand
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		--● Reveal 1 "Witchcrafter" Normal or Quick-Play Spell in your hand; apply that Spell's activation effect
		e:SetCategory(0)
		local revealed_card=e:GetLabelObject():GetFirst()
		local te,ceg,cep,cev,cre,cr,crp=revealed_card:CheckActivateEffect(true,true,true)
		Duel.ClearTargetCard()
		local tg=te:GetTarget()
		e:SetProperty(te:GetProperty())
		if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
		te:SetLabelObject(e:GetLabelObject())
		e:SetLabelObject(te)
		e:SetCategory(0)
		Duel.ClearOperationInfo(0)
	end
	Duel.SetTargetParam(op)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then
		--● Add 1 "Witchcrafter" Spell from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--● Reveal 1 "Witchcrafter" Normal or Quick-Play Spell in your hand; apply that Spell's activation effect
		local te=e:GetLabelObject()
		if not te then return end
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then
			op(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.rtgfilter(c)
	return c:IsSetCard(SET_WITCHCRAFTER) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.rtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
end
function s.rtgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.rtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
