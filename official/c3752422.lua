--EMレ・ベルマン
--Performapal Lebellman
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--level up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	--level change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x9f}
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:HasLevel()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		tc:UpdateLevel(1,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,e:GetHandler())
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:HasLevel()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return c:GetLevel()>1
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c) end
	local p=math.min(c:GetLevel()-1,5)
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,p)
	Duel.SetTargetParam(lv)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:UpdateLevel(-lv,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)~=0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
			tc:UpdateLevel(lv,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,c)
		end
	end
end
