--As I Predicted...!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_EXCHANGE_SPIRIT} --"Exchange of the Spirit"
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Look at the top 2 cards, add 1 to your hand and send the other to your GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.GetDrawCount(tp)>0 and Duel.GetTurnCount(tp)>1 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end)
	e1:SetOperation(s.drawop)
	Duel.RegisterEffect(e1,tp)
	--Apply the following Skills:
	--● Only you need 15 or more cards in your GY to activate "Exchange of the Spirit".
	--● If you have 15 or more cards in your GY, you can banish 1 "Exchange of the Spirit" from your GY to activate its effect.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)	
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(0x5f)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_ADJUST)
	e2b:SetOperation(s.altexchangeop)
	Duel.RegisterEffect(e2b,tp)
end
--Draw functions
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	--Look at the top 2 cards of your Deck, add 1 and send the other to the GY
	local dt=Duel.GetDrawCount(tp)
	if dt==0 then return false end
	_replace_count=1
	_replace_max=dt
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_DRAW)
	e1:SetValue(0)
	Duel.RegisterEffect(e1,tp)
	if _replace_count>_replace_max then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.GetDecktopGroup(tp,2)
	Duel.ConfirmCards(tp,g)
	if #g==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			g:RemoveCard(tc)
			if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
				Duel.ConfirmCards(1-tp,tc)
				Duel.BreakEffect()
				if Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
					--Skip your next Battle Phase
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetDescription(aux.Stringid(id,1))
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetCode(EFFECT_SKIP_BP)
					e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
					e1:SetTargetRange(1,0)
					e1:SetReset(RESET_PHASE|PHASE_END)
					Duel.RegisterEffect(e1,tp)
				end
			end
		end
	end
end
function s.altexchangeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,LOCATION_ALL,nil,CARD_EXCHANGE_SPIRIT)
	for tc in g:Iter() do
		if not tc:HasFlagEffect(id) then
			tc:RegisterFlagEffect(id,0,0,0)
			--Only you need 15 or more cards in your GY to activate "Exchange of the Spirit"
			local eff=tc:GetActivateEffect()
			eff:SetCondition(function(e,tp)
						return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=15 and (Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=15 or Duel.IsPlayerAffectedByEffect(tp,id))
					end)
			--If you have 15 or more cards in your GY, you can banish 1 "Exchange of the Spirit" from your GY to activate its effect
			local gy_eff=eff:Clone()
			gy_eff:SetType(EFFECT_TYPE_QUICK_O)
			gy_eff:SetRange(LOCATION_GRAVE)
			gy_eff:SetCountLimit(1)
			gy_eff:SetCost(Cost.SelfBanish)
			tc:RegisterEffect(gy_eff)
		end
	end
end