--ライブラの魔法秤
--Magicalibra
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum properties
	Pendulum.AddProcedure(c)
	--Change levels
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
end
function s.lvfilter(c,e)
	return c:IsFaceup() and c:HasLevel() and c:IsCanBeEffectTarget(e) 
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,e)
	local _,hlv=g:GetMaxGroup(Card.GetLevel)
	if chk==0 then return #g>1 and hlv>1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,math.min(hlv-1,6))
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,function(sg)return sg:IsExists(Card.IsLevelAbove,1,nil,lv+1)end,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(tg)
	Duel.SetTargetParam(lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if not c:IsRelateToEffect(e) or #tg<1 then return end
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END
	if #tg==1 then
		local tc=tg:GetFirst()
		if tc:GetLevel()<=lv then return end
		tc:UpdateLevel(-lv,reset,c)
	elseif #tg==2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local rd=tg:FilterSelect(tp,Card.IsLevelAbove,1,1,nil,lv+1):GetFirst()
		if rd and rd:UpdateLevel(-lv,reset,c)~=0 then
			(tg-rd):GetFirst():UpdateLevel(lv,reset,c)
		end
	end
end