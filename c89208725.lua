--メタバース
--Metaverse
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsType(TYPE_FIELD) and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	if not Duel.CheckPhaseActivity() then Duel.RegisterFlagEffect(tp,CARD_MAGICAL_MIDBREAKER,RESET_CHAIN,0,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	aux.ToHandOrElse(tc,tp,function(c)
                            local te=tc:GetActivateEffect()
                            return te:IsActivatable(tp,true,true)
                        end, function(c)
                            local te=tc:GetActivateEffect()
                            local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
                            if fc then
                                Duel.SendtoGrave(fc,REASON_RULE)
                                Duel.BreakEffect()
                            end
                            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
                            local tep=tc:GetControler()
                            local cost=te:GetCost()
                            if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
                            Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
                        end,
						aux.Stringid(id,2))
end