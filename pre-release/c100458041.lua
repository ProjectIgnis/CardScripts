--異解△審判
--Xenovader△ Judgment
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--If your opponent Normal or Special Summons a monster(s): You can target 1 of them; choose 1 of your face-down banished "Xenovader△" monsters with the same Attribute, and either add it to your hand or Special Summon it, also for the rest of this turn, you cannot choose the same Attribute again with this effect of "Xenovader△ Judgment", and you cannot activate cards or effects, except "Xenovader△" cards or effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function() return not Duel.IsDamageStep() end)
	e1:SetTarget(s.thsptg)
	e1:SetOperation(s.thspop)
	c:RegisterEffect(e1)
	--Keep track of the Normal or Special Summoned monsters
	aux.GlobalCheck(s,function()
		s.sumgroup=Group.CreateGroup()
		s.sumgroup:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.sumgroupregop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
		--Keep track of the chosen monsters' Attributes
		s.attr_list={}
		s.attr_list[0]=0
		s.attr_list[1]=0
		aux.AddValuesReset(function()
			s.attr_list[0]=0
			s.attr_list[1]=0
		end)
	end)
	--Once per battle, during damage calculation, if your "Xenovader△" monster battles an opponent's monster and you have no cards in your Deck: You can make that opponent's monster's ATK become 0
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(Cost.SoftOncePerBattle)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_XENOVADER}
s.listed_names={id}
function s.sumgroupregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(Card.IsFaceup,nil)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		if Duel.GetCurrentChain()==0 then s.sumgroup:Clear() end
		s.sumgroup:Merge(tg)
		s.sumgroup:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		Duel.RaiseEvent(s.sumgroup,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.tgfilter(c,e,tp,opp,mmz_chk)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e) and c:IsSummonPlayer(opp)
		and Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,mmz_chk,c:GetAttribute())
end
function s.thspfilter(c,e,tp,mmz_chk,attr)
	return c:IsFacedown() and c:IsSetCard(SET_XENOVADER) and c:IsAttribute(attr) and s.attr_list[tp]&c:GetAttribute()==0
		and (c:IsAbleToHand() or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local g=s.sumgroup:Filter(s.tgfilter,nil,e,tp,1-tp,mmz_chk)
	if chkc then return g:IsContains(chkc) and g:IsExists(s.tgfilter,1,nil,e,tp,1-tp,mmz_chk) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
		Duel.SetTargetCard(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.SetTargetCard(tc)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,mmz_chk,tc:GetAttribute()):GetFirst()
		if sc then
			--For the rest of this turn, you cannot choose the same Attribute again with this effect of "Xenovader△ Judgment"
			local attr=sc:GetAttribute()
			s.attr_list[tp]=s.attr_list[tp]|attr
			aux.ToHandOrElse(sc,tp,
				function()
					return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				end,
				function()
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				end,
				aux.Stringid(id,3)
			)
			if sc:IsLocation(LOCATION_HAND) then Duel.ConfirmCards(1-tp,sc) end
			for _,str in aux.GetAttributeStrings(attr) do
				c:RegisterFlagEffect(0,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,str)
			end
		end
	end
	--You cannot activate cards or effects for the rest of this turn, except "Xenovader△" cards or effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re) return not re:GetHandler():IsSetCard(SET_XENOVADER) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then return false end
	local bc1,bc2=Duel.GetBattleMonster(tp)
	return bc1 and bc1:IsSetCard(SET_XENOVADER) and bc2 and bc2:IsControler(1-tp) and bc2:HasNonZeroAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local _,bc=Duel.GetBattleMonster(tp)
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		--Make that opponent's monster's ATK become 0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end