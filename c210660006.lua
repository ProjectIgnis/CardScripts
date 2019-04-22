--Wicked Insight
function c210660006.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210660006+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c210660006.target)
	e1:SetOperation(c210660006.operation)
	c:RegisterEffect(e1)
end
function c210660006.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	--c:IsSetCard(0xf66) or c:IsCode(21208154,57793869,62180201)
	c210660006.announce_filter={0xf66,OPCODE_ISSETCARD,21208154,OPCODE_ISCODE,OPCODE_OR,57793869,OPCODE_ISCODE,OPCODE_OR,62180201,OPCODE_ISCODE,OPCODE_OR}
	local ac=Duel.AnnounceCardFilter(tp,table.unpack(c210660006.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function c210660006.filter(c,e,tp)
	return c:IsCode(21208154,57793869,62180201) and c:IsAbleToHand()
end
function c210660006.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(c210660006.filter,tp,LOCATION_DECK,0,nil)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if g:GetCount()>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(39913299,1)) then
			Duel.BreakEffect()
			local ct=1
			if ft>3 then ct=3 else ct=ft end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39913299,1))
			local sg=g:Select(tp,1,ct,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetRange(LOCATION_SZONE)
			e1:SetCode(EFFECT_CANNOT_RELEASE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetReset(RESET_CHAIN)
			e1:SetTargetRange(1,0)
			Duel.RegisterEffect(e1,tp)
			for tc in aux.Next(sg) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(78651105,0))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
				e1:SetCondition(c210660006.ntcon)
				e1:SetReset(RESET_CHAIN)
				tc:RegisterEffect(e1)
				Duel.Summon(tp,tc,true,nil)
			end
		else
			Duel.DisableShuffleCheck()
		end
		Duel.ShuffleHand(tp)
	else
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
function c210660006.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end