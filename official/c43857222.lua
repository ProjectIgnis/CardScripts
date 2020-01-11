--ライブラの魔法秤
--Magical Scales of Libra
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--pendulum
	Pendulum.AddProcedure(c)
	--modify levels
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
function s.filter(c,tp,lv)
	return c:IsFaceup() and c:GetLevel()>lv and Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.HasLevel),tp,LOCATION_MZONE,0,1,c)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local _,val=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetLevel)
	if not val or val<2 then return false end
	local lv=math.min(val-1,6)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local dlv=Duel.AnnounceLevel(tp,1,lv)
	Duel.SetTargetParam(dlv)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp,dlv)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g2=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.HasLevel),tp,LOCATION_MZONE,0,1,1,g1)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local tc=e:GetLabelObject()
		if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:UpdateLevel(-lv,nil,c)~=0 then
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			g:RemoveCard(tc)
			local tc2=g:GetFirst()
			if tc2==tc then tc2=g:GetNext() end
			if tc2 and tc2:IsFaceup() and tc2:IsRelateToEffect(e) then
				 tc2:UpdateLevel(lv,nil,c)
			end
		end
	end
end
