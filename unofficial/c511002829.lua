--熱血指導王ジャイアントレーナー
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(30741334,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.ShuffleDeck(tp,REASON_EFFECT)
	Duel.ShuffleDeck(1-tp,REASON_EFFECT)
	local tc1=Duel.GetDecktopGroup(tp,1):GetFirst()
	local tc2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.Draw(1-tp,1,REASON_EFFECT)
	if tc1 and tc2 then
		Duel.ConfirmCards(1-tp,tc1)
		Duel.ConfirmCards(tp,tc2)
		if tc1:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
			Duel.BreakEffect()
			if tc1:GetLevel()<tc2:GetLevel() then
				Duel.Damage(tp,800,REASON_EFFECT)
			elseif tc1:GetLevel()>tc2:GetLevel() then
				Duel.Damage(1-tp,800,REASON_EFFECT)
			end
		end
		Duel.BreakEffect()
		local g=Group.CreateGroup()
		g:AddCard(tc1)
		g:AddCard(tc2)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
