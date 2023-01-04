--Alchemicalize Salamandra
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMix(c,true,true,160010020,160316023)
	--Draw and summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local dg=Duel.GetOperatedGroup()
		local atk=dg:FilterCount(Card.IsSpell,nil)*1000
		local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #sg>0 and atk>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			for tc in sg:Iter() do
				--Decrease ATK
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffectRush(e1)
			end
		end
	end
end