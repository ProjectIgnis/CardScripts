--Brutal Beast Battle
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.types={TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		for p=0,1 do
			for _,t in ipairs(s.types) do
				if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,t),p,LOCATION_MZONE,0,2,nil) then
					return true
				end
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.cancelcon(sg,e,tp,mg)
	for _,t in ipairs(s.types) do
		if mg:IsExists(Card.IsType,1,nil,t) and mg:FilterCount(Card.IsType,sg,t)~=1 then
			return false 
		end
	end
	return true
end
function s.typecount(p)
	local ct=0
	for _,t in ipairs(s.types) do
		if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,t),p,LOCATION_MZONE,0,1,nil) then
			ct=ct+1
		end
	end
	return ct
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local draw={}
	draw[0]=false
	draw[1]=false
	for p=0,1 do
		local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
		for _,t in ipairs(s.types) do
			if g:FilterCount(Card.IsType,nil,t)==1 then
				g:Remove(Card.IsType,nil,t)
			end
		end
		if #g>0 then
			local tg=aux.SelectUnselectGroup(g,e,tp,1,99,s.cancelcon,1,tp,HINTMSG_TOGRAVE,s.cancelcon)
			if Duel.SendtoGrave(tg,nil,REASON_EFFECT)>0 then
				draw[p]=true
			end
		end
	end
	if draw[tp] or draw[1-tp] then
		Duel.BreakEffect()
		if draw[tp] then
			Duel.Draw(tp,s.typecount(tp),REASON_EFFECT)
		end
		if draw[1-tp] then
			Duel.Draw(1-tp,s.typecount(1-tp),REASON_EFFECT)
		end
	end
end

