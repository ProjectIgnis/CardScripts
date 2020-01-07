--Summon Pass
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.sumcon)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	return c:IsOnField() and c:IsLevelBelow(4)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tc:GetControler(),1)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local p=tc:GetControler()
		local hc=Duel.GetDecktopGroup(1-p,1):GetFirst()
		Duel.Draw(1-p,1,REASON_EFFECT)
		if hc then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
			local op=Duel.SelectOption(p,70,71,72)
			Duel.ConfirmCards(p,hc)
			Duel.ShuffleHand(1-p)
			if (op~=0 and hc:IsType(TYPE_MONSTER)) or (op~=1 and hc:IsType(TYPE_SPELL)) or (op~=2 and hc:IsType(TYPE_TRAP)) then
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end
