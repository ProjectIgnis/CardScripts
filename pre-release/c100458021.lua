--レイズ・ムーンの朔 スクイーズ
--Raise Moon Starter Squeeze
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--(Quick Effect): You can discard this card, then activate 1 of these effects (but you can only use each of these effects of "Raise Moon Starter Squeeze" once per turn);
	--● You cannot Special Summon from the Extra Deck until the end of the next turn, except Rank 7 Xyz Monsters, also this turn, each time a card(s) is added to your opponent's hand, except by drawing it, immediately draw 1 card
	--● Draw 1 card
	--You cannot add cards from the Deck to the hand during the Duel you activate this effect, except by drawing them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(Cost.AND(Cost.SelfDiscard,s.effcost))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Keep track of cards being added to a player's hand, except by drawing them
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			for ec in eg:Iter() do
				if ec:IsPreviousLocation(LOCATION_DECK) and not ec:IsReason(REASON_DRAW) then
					Duel.RegisterFlagEffect(ec:GetReasonPlayer(),id,0,0,1)
				end
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	--You cannot add cards from the Deck to the hand during the Duel you activate this effect, except by drawing them
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,tp,re)
		return c:IsLocation(LOCATION_DECK)
	end)
	Duel.RegisterEffect(e1,tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● You cannot Special Summon from the Extra Deck until the end of the next turn, except Rank 7 Xyz Monsters, also this turn, each time a card(s) is added to your opponent's hand, except by drawing it, immediately draw 1 card
	local option_1=not Duel.HasFlagEffect(tp,id+100)
	--● Draw 1 card
	local option_2=not Duel.HasFlagEffect(tp,id+200)
		and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)})
	e:GetChainData().choice=choice
	if choice==1 then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif choice==2 then
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● You cannot Special Summon from the Extra Deck until the end of the next turn, except Rank 7 Xyz Monsters, also this turn, each time a card(s) is added to your opponent's hand, except by drawing it, immediately draw 1 card
		local c=e:GetHandler()
		--You cannot Special Summon from the Extra Deck until the end of the next turn, except Rank 7 Xyz Monsters
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c)
			return c:IsLocation(LOCATION_EXTRA) and not (c:IsRank(7) and c:IsXyzMonster())
		end)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,5))
		--This turn, each time a card(s) is added to your opponent's hand, except by drawing it, immediately draw 1 card
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_TO_HAND)
		e2:SetCondition(s.drcon)
		e2:SetOperation(s.drop)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	elseif choice==2 then
		--● Draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.drconfilter(c,opp)
	return c:IsControler(opp) and not c:IsReason(REASON_DRAW)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drconfilter,1,nil,1-tp)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainSolving() then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		local eff=e:GetLabelObject()
		if eff and not eff:IsDeleted() then
			eff:SetLabel(eff:GetLabel()+1)
		else
			local c=e:GetHandler()
			--Draw cards when the current Chain Link finishes resolving
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetOperation(s.chainsolvedop)
			e1:SetLabel(1)
			e1:SetLabelObject(e)
			e1:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e1,tp)
			e:SetLabelObject(e1)
			--Reset "e1" and the label object of "e" at the end of the Chain Link
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVED)
			e2:SetOperation(function() e:SetLabelObject(nil) e1:Reset() end)
			e2:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.chainsolvedop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
	e:Reset()
	e:GetLabelObject():SetLabelObject(nil)
end