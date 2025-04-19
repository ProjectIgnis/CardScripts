--ブラック・マジシャン (Deck Master)
--Dark Magician (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCondition(s.con)
	dme1:SetOperation(s.op)
	DeckMaster.RegisterAbilities(c,dme1)
	aux.GlobalCheck(s,function()
		s.usedSpell=Group.CreateGroup()
		s.usedSpell:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s.usedSpell:Clear()
		end)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		s.usedSpell:AddCard(re:GetHandler())
	end
end
function s.filter(c,p)
	if not c:IsSpell() then return false end
	local te=c:CheckActivateEffect(false,false,false)
	return te and te:IsActivatable(p,true)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.IsDeckMaster(tp,id)
		and Duel.CheckLPCost(tp,1000) and s.usedSpell:IsExists(s.filter,1,nil,tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.PayLPCost(tp,1000)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local te=s.usedSpell:FilterSelect(tp,s.filter,1,1,nil,tp):GetFirst():GetActivateEffect()
	Duel.Activate(te)
end