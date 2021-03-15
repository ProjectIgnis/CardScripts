--繋がれし魔鍵
--Connected Magikey
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local fparams={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x262),sumpos=POS_FACEUP_DEFENSE}
	local rparams={filter=aux.FilterBoolFunction(Card.IsSetCard,0x262),lvtype=RITPROC_GREATER,sumpos=POS_FACEUP_DEFENSE}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(fparams),Fusion.SummonEffOP(fparams),Ritual.Target(rparams),Ritual.Operation(rparams)))
	c:RegisterEffect(e1)
end
s.listed_series={0x262}
function s.filter(c)
	return (c:IsSetCard(0x262) or c:IsType(TYPE_NORMAL)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.operation(fustg,fusop,rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
			local fus=fustg(e,tp,eg,ep,ev,re,r,rp,0)
			local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
			if fus or rit then
				local sel={}
				table.insert(sel,aux.Stringid(id,1))
				if fus then table.insert(sel,aux.Stringid(id,2)) end
				if rit then table.insert(sel,aux.Stringid(id,3)) end
				local res=Duel.SelectOption(tp,false,table.unpack(sel))
				if res==0 then return end
				Duel.BreakEffect()
				if res==1 and fus then
					Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
					fusop(e,tp,eg,ep,ev,re,r,rp)
				else
					Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
					ritop(e,tp,eg,ep,ev,re,r,rp)
				end
			end
		end
	end
end