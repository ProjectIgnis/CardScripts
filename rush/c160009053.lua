-- ゴースト・サイクロン
--Ghost Cyclone

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 spell/trap your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
	--Check for spell/trap
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,e:GetHandler())
	if chkc then return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return #dg>0 end
end
	--Send 1 card from hand to GY to destroy 1 spell/trap your opponent controls
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	--Effect
	if Duel.SendtoGrave(g,REASON_COST)~=0 then
		local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,e:GetHandler())
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
			if (not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,4,nil,TYPE_MONSTER)) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
