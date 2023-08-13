--アミュージー・アノイアンス
--Amusi Annoyance
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Increase the ATK of 1 monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
	--Register cards sent
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetRange(LOCATION_SZONE)
	e0:SetLabelObject(e1)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	Duel.RegisterEffect(e0,0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.regop2)
	Duel.RegisterEffect(e2,0)
	--cannot use global effect here because labels wouldn't be properly registered on different copies
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return ct>0 and Duel.IsMainPhase() and Duel.IsTurnPlayer(1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
	if e:GetLabel()>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,1)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local ct=#dg
	if ct>0 and Duel.Damage(1-tp,ct*300,REASON_EFFECT)>0 and e:GetLabel()>0 then
		local g=dg:RandomSelect(tp,1)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsMainPhase() and Duel.IsTurnPlayer(1-tp)
end
function s.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:GetOwner()==tp
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Use the label object of e1 to store the cards
	local g=e:GetLabelObject():GetLabelObject()
	g:Merge(eg)
	e:GetLabelObject():SetLabelObject(g)
	--Use the label of e1 to see if there were cards from the deck
	if g:IsExists(s.filter,1,nil,1-tp) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
	--Raise 1 event per chain
	if Duel.GetCurrentChain()==0 then
		g:Clear()
		if Duel.GetFlagEffect(tp,id)==0 then
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLocation(LOCATION_SZONE) and e:GetHandler():IsFacedown() then --need to check here because face-down Defense Position cards cannot use effects
		local cg=e:GetLabelObject():GetLabelObject()
		--Raise 1 event after chain
		if Duel.GetFlagEffect(tp,id)==0 and #cg>0 then
			if not cg:IsExists(s.filter,1,nil,1-tp) then -- The following does not apply if a card is sent from the Deck, as in that case, the first copy will trigger the second copy
				cg:Clear() --Must be cleared so multiple copies cannot trigger
			end
			Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end